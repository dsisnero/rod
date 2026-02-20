require "../pdl"
require "../fixup"
require "./crystal_util"
require "./emitter"

module Pdlgen
  module Gen
    # CrystalGenerator generates Crystal source code for the Chrome DevTools Protocol.
    class CrystalGenerator < Emitter
      getter files : Hash(String, String)

      def initialize
        @files = Hash(String, String).new
      end

      def self.create(domains : Array(Pdl::Domain), base_pkg : String) : Emitter
        generator = new
        generator.generate(domains, base_pkg)
        generator
      end

      def emit : Hash(String, String)
        @files
      end

      protected def generate(domains : Array(Pdl::Domain), base_pkg : String)
        # Apply fixup first
        Fixup.fix_domains(domains)

        # Generate shared types (circular dependencies)
        generate_shared_types(domains, base_pkg)

        # Generate root package
        generate_root_package(domains, base_pkg)

        # Generate individual domains
        domains.each do |d|
          # Skip deprecated domains
          next if d.deprecated

          pkg_name = CrystalUtil.package_name(d)

          # Generate main domain file
          domain_content = generate_domain_module(d, domains, base_pkg)
          add_file("#{pkg_name}/#{pkg_name}.cr", domain_content)

          # Generate domain types file if there are types
          if !d.types.empty?
            types_content = generate_types(d, domains, base_pkg)
            add_file("#{pkg_name}/types.cr", types_content)
          end

          # Generate domain events file if there are events
          if !d.events.empty?
            events_content = generate_events(d, domains, base_pkg)
            add_file("#{pkg_name}/events.cr", events_content)
          end
        end
      end

      private def generate_shared_types(domains : Array(Pdl::Domain), base_pkg : String)
        # Find circular dependency types
        typs = [] of Pdl::Type
        domains.each do |d|
          d.types.each do |t|
            if t.is_circular_dep
              typs << t
            end
          end
        end

        return if typs.empty?

        content = String.build do |io|
          io << "# Shared Chrome DevTools Protocol Domain types.\n"
          io << "module Cdp\n"
          typs.each do |t|
            generate_type_struct(io, t, nil, domains)
          end
          io << "end\n"
        end

        add_file("cdp/types.cr", content)
      end

      private def generate_root_package(domains : Array(Pdl::Domain), base_pkg : String)
        # Generate root package with basic types
        content = String.build do |io|
          io << "require \"json\"\n"
          io << "require \"http\"\n"
          io << "\n"
          io << "# Chrome DevTools Protocol types.\n"
          io << "module Cdp\n"
          io << "  # Chrome DevTools Protocol method type (ie, event and command names).\n"
          io << "  alias MethodType = String\n"
          io << "  \n"
          io << "  # Error type.\n"
          io << "  struct Error\n"
          io << "    property code : Int32\n"
          io << "    property message : String\n"
          io << "    \n"
          io << "    def initialize(@code, @message)\n"
          io << "    end\n"
          io << "    \n"
          io << "    # Error satisfies the error interface.\n"
          io << "    def to_s : String\n"
          io << "      \"\#{message} (\#{code})\"\n"
          io << "    end\n"
          io << "  end\n"
          io << "  \n"
          io << "  # Client interface to send the request.\n"
          io << "  # So that this lib doesn't handle anything has side effect.\n"
          io << "  abstract class Client\n"
          io << "    abstract def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes\n"
          io << "  end\n"
          io << "  \n"
          io << "  # Sessionable type has a session ID for its methods.\n"
          io << "  module Sessionable\n"
          io << "    abstract def session_id : String?\n"
          io << "  end\n"
          io << "  \n"
          io << "  # Contextable type has a context for its methods.\n"
          io << "  module Contextable\n"
          io << "    abstract def context : HTTP::Client::Context?\n"
          io << "  end\n"
          io << "  \n"
          io << "  # Request represents a cdp.Request.Method.\n"
          io << "  module Request\n"
          io << "    abstract def proto_req : String\n"
          io << "  end\n"
          io << "  \n"
          io << "  # Event represents a cdp.Event.Params.\n"
          io << "  module Event\n"
          io << "    abstract def proto_event : String\n"
          io << "  end\n"
          io << "  \n"
          io << "  # GetType from method name of this package,\n"
          io << "  # such as Cdp.get_type(\"Page.enable\") will return the type of Cdp::Page::Enable.\n"
          io << "  def self.get_type(method_name : String) : Class\n"
          io << "    # TODO: Implement type lookup from method name\n"
          io << "    raise \"Not implemented: get_type for \#{method_name}\"\n"
          io << "  end\n"
          io << "  \n"
          io << "  # ParseMethodName to domain and name.\n"
          io << "  def self.parse_method_name(method : String) : Tuple(String, String)\n"
          io << "    arr = method.split('.')\n"
          io << "    {arr[0], arr[1]}\n"
          io << "  end\n"
          io << "  \n"
          io << "  # call method with request and response containers.\n"
          io << "  def self.call(method : String, req : Request, res : JSON::Serializable?, c : Client) : Nil\n"
          io << "    ctx = nil\n"
          io << "    if c.is_a?(Contextable)\n"
          io << "      ctx = c.context\n"
          io << "    end\n"
          io << "    \n"
          io << "    session_id = nil\n"
          io << "    if c.is_a?(Sessionable)\n"
          io << "      session_id = c.session_id\n"
          io << "    end\n"
          io << "    \n"
          io << "    params = req.to_json\n"
          io << "    bin = c.call(ctx, session_id, method, JSON.parse(params))\n"
          io << "    if res\n"
          io << "      res.from_json(String.new(bin))\n"
          io << "    end\n"
          io << "    nil\n"
          io << "  end\n"
          io << "end\n"
        end

        add_file("cdp.cr", content)
      end

      private def collect_referenced_domains(d : Pdl::Domain, domains : Array(Pdl::Domain)) : Array(String)
        referenced = Set(String).new

        # Check types
        d.types.each do |t|
          collect_references_from_type(t, d, domains, referenced)
        end

        # Check commands
        d.commands.each do |c|
          c.parameters.each do |p|
            collect_references_from_type(p, d, domains, referenced)
          end
          c.returns.each do |r|
            collect_references_from_type(r, d, domains, referenced)
          end
        end

        # Check events
        d.events.each do |e|
          e.parameters.each do |p|
            collect_references_from_type(p, d, domains, referenced)
          end
        end

        referenced.to_a
      end

      private def collect_references_from_type(t : Pdl::Type, d : Pdl::Domain, domains : Array(Pdl::Domain), referenced : Set(String))
        return if t.ref.empty?

        # Parse ref to get domain
        n = t.ref.split('.', 2)
        ref_domain = n[0]

        # Check if it's a different domain
        if ref_domain != d.domain && domains.any? { |dom| dom.domain == ref_domain }
          referenced << ref_domain.downcase
        end

        # Check array items
        if t.type == Pdl::TypeEnum::Array && t.items
          collect_references_from_type(t.items.not_nil!, d, domains, referenced)
        end
      end

      private def generate_domain_module(d : Pdl::Domain, domains : Array(Pdl::Domain), base_pkg : String) : String
        String.build do |io|
          # Add require statements
          io << "require \"json\"\n"
          io << "require \"../cdp\"\n"

          referenced_domains = collect_referenced_domains(d, domains)
          referenced_domains.each do |ref_domain|
            next if ref_domain == d.domain.downcase
            io << "require \"../#{ref_domain}/#{ref_domain}\"\n"
          end

          # Require types file if domain has types
          if !d.types.empty?
            io << "require \"./types\"\n"
          end

          io << "\n"
          format_description(io, d.description)
          if d.deprecated
            io << "@[Deprecated(\"This domain is deprecated\")]\n"
          end
          if d.experimental
            io << "@[Experimental]\n"
          end
          io << "module #{base_pkg}::#{d.domain.camelcase}\n"

          # Commands
          if !d.commands.empty?
            io << "  # Commands\n"
            d.commands.each do |c|
              next if c.deprecated && !c.always_emit

              if c.deprecated
                io << "  @[Deprecated]\n"
              end
              if c.experimental
                io << "  @[Experimental]\n"
              end

              cmd_type = CrystalUtil.command_type(c)
              io << "  struct #{cmd_type}\n"
              io << "    include JSON::Serializable\n"
              io << "    include Cdp::Request\n\n"
              # Properties
              c.parameters.each do |p|
                next if p.deprecated && !p.always_emit
                next if p.name.empty?

                type_str = CrystalUtil.crystal_type(p, d, domains)
                io << "    @[JSON::Field(emit_null: false)]\n" if p.optional
                io << "    property #{p.name.underscore} : #{type_str}"
                io << "?" if p.optional
                io << "\n"
              end

              # Constructor
              io << "    \n"
              io << "    def initialize("
              params = c.parameters.map do |p|
                next if p.deprecated && !p.always_emit
                next if p.name.empty?
                "@#{p.name.underscore} : #{CrystalUtil.crystal_type(p, d, domains)}#{'?' if p.optional}"
              end.compact
              io << params.join(", ")
              io << ")\n"
              io << "    end\n"
              io << "    \n"
              io << "    # ProtoReq returns the protocol method name.\n"
              io << "    def proto_req : String\n"
              io << "      \"#{d.domain}.#{c.name}\"\n"
              io << "    end\n"
              io << "    \n"
              # Call method
              if !c.returns.empty?
                returns_type = CrystalUtil.command_returns_type(c)
                io << "    # Call sends the request and returns the result.\n"
                io << "    def call(c : Cdp::Client) : #{returns_type}\n"
                io << "      res = #{returns_type}.new\n"
                io << "      Cdp.call(proto_req, self, res, c)\n"
                io << "      res\n"
                io << "    end\n"
              else
                io << "    # Call sends the request.\n"
                io << "    def call(c : Cdp::Client) : Nil\n"
                io << "      Cdp.call(proto_req, self, nil, c)\n"
                io << "    end\n"
              end
              io << "  end\n"
              io << "\n"

              # Generate return type if command has returns
              if !c.returns.empty?
                if c.deprecated
                  io << "  @[Deprecated]\n"
                end
                if c.experimental
                  io << "  @[Experimental]\n"
                end

                returns_type = CrystalUtil.command_returns_type(c)
                io << "  struct #{returns_type}\n"
                io << "    include JSON::Serializable\n\n"

                c.returns.each do |r|
                  next if r.deprecated && !r.always_emit

                  type_str = CrystalUtil.crystal_type(r, d, domains)
                  io << "    @[JSON::Field(emit_null: false)]\n" if r.optional
                  io << "    property #{r.name.underscore} : #{type_str}"
                  io << "?" if r.optional
                  io << "\n"
                end

                io << "    \n"
                io << "    def initialize("
                params = c.returns.map do |r|
                  next if r.deprecated && !r.always_emit
                  "@#{r.name.underscore} : #{CrystalUtil.crystal_type(r, d, domains)}#{'?' if r.optional}"
                end.compact
                io << params.join(", ")
                io << ")\n"
                io << "    end\n"
                io << "  end\n"
                io << "\n"
              end
            end
          end

          io << "end\n"
        end
      end

      private def generate_types(d : Pdl::Domain, domains : Array(Pdl::Domain), base_pkg : String) : String
        String.build do |io|
          io << "require \"../#{CrystalUtil.package_name(d)}/#{CrystalUtil.package_name(d)}\"\n"
          io << "require \"json\"\n"
          io << "require \"time\"\n"

          referenced_domains = collect_referenced_domains(d, domains)
          referenced_domains.each do |ref_domain|
            next if ref_domain == d.domain.downcase
            io << "require \"../#{ref_domain}/#{ref_domain}\"\n"
          end

          io << "\n"
          io << "module #{base_pkg}::#{d.domain.camelcase}\n"

          d.types.each do |t|
            next if t.is_circular_dep || t.deprecated && !t.always_emit

            generate_type_struct(io, t, d, domains)
          end

          io << "end\n"
        end
      end

      private def generate_events(d : Pdl::Domain, domains : Array(Pdl::Domain), base_pkg : String) : String
        String.build do |io|
          io << "require \"../#{CrystalUtil.package_name(d)}/#{CrystalUtil.package_name(d)}\"\n"
          io << "require \"json\"\n"
          io << "require \"time\"\n"

          referenced_domains = collect_referenced_domains(d, domains)
          referenced_domains.each do |ref_domain|
            next if ref_domain == d.domain.downcase
            io << "require \"../#{ref_domain}/#{ref_domain}\"\n"
          end

          io << "\n"
          io << "module #{base_pkg}::#{d.domain.camelcase}\n"

          d.events.each do |e|
            next if e.deprecated && !e.always_emit

            if e.deprecated
              io << "  @[Deprecated]\n"
            end
            if e.experimental
              io << "  @[Experimental]\n"
            end

            io << "  struct #{e.name.camelcase}Event\n"
            io << "    include JSON::Serializable\n"
            io << "    include Cdp::Event\n\n"
            # Properties
            e.parameters.each do |p|
              next if p.deprecated && !p.always_emit
              next if p.name.empty?

              type_str = CrystalUtil.crystal_type(p, d, domains)
              io << "    @[JSON::Field(emit_null: false)]\n" if p.optional
              io << "    property #{p.name.underscore} : #{type_str}"
              io << "?" if p.optional
              io << "\n"
            end

            # Constructor
            io << "    \n"
            io << "    def initialize("
            params = e.parameters.map do |p|
              next if p.deprecated && !p.always_emit
              next if p.name.empty?
              "@#{p.name.underscore} : #{CrystalUtil.crystal_type(p, d, domains)}#{'?' if p.optional}"
            end.compact
            io << params.join(", ")
            io << ")\n"
            io << "    end\n"
            io << "    \n"
            io << "    # ProtoEvent returns the protocol event name.\n"
            io << "    def proto_event : String\n"
            io << "      \"#{d.domain}.#{e.name}\"\n"
            io << "    end\n"
            io << "  end\n"
            io << "\n"
          end

          io << "end\n"
        end
      end

      private def generate_type_struct(io : IO, t : Pdl::Type, d : Pdl::Domain?, domains : Array(Pdl::Domain))
        if t.deprecated
          io << "  @[Deprecated]\n"
        end
        if t.experimental
          io << "  @[Experimental]\n"
        end

        case t.type
        when Pdl::TypeEnum::Object
          if (enum_values = t.enum) && !enum_values.empty?
            # Enum type
            io << "  enum #{type_name_for_domain(t, d)}\n"
            enum_values.each do |value|
              io << "    #{value.camelcase}\n"
            end
            io << "  end\n"
          else
            # Struct type
            io << "  struct #{type_name_for_domain(t, d)}\n"
            io << "    include JSON::Serializable\n\n"
            if t.properties && !t.properties.empty?
              t.properties.each do |p|
                next if p.deprecated && !p.always_emit
                next if p.name.empty?

                type_str = d ? CrystalUtil.crystal_type(p, d, domains) : "JSON::Any"
                io << "    @[JSON::Field(emit_null: false)]\n" if p.optional
                io << "    property #{p.name.underscore} : #{type_str}"
                io << "?" if p.optional
                io << "\n"
              end
            end
            io << "  end\n"
          end
        when Pdl::TypeEnum::String
          io << "  alias #{type_name_for_domain(t, d)} = String\n"
        when Pdl::TypeEnum::Integer
          io << "  alias #{type_name_for_domain(t, d)} = Int64\n"
        when Pdl::TypeEnum::Boolean
          io << "  alias #{type_name_for_domain(t, d)} = Bool\n"
        when Pdl::TypeEnum::Number
          io << "  alias #{type_name_for_domain(t, d)} = Float64\n"
        when Pdl::TypeEnum::Any
          io << "  alias #{type_name_for_domain(t, d)} = JSON::Any\n"
        when Pdl::TypeEnum::Timestamp
          io << "  alias #{type_name_for_domain(t, d)} = Time\n"
        when Pdl::TypeEnum::Binary
          io << "  alias #{type_name_for_domain(t, d)} = String\n"
        else
          io << "  # TODO: Implement type #{t.type} for #{t.name}\n"
          io << "  alias #{type_name_for_domain(t, d)} = JSON::Any\n"
        end
        io << "\n"
      end

      # Format a description as a comment block
      private def format_description(io : IO, description : String)
        return if description.empty?
        description.each_line do |line|
          io << "# " << line.strip << "\n"
        end
      end

      # Get type name for definition in current domain
      private def type_name_for_domain(t : Pdl::Type, d : Pdl::Domain?) : String
        name = t.name.camelcase
        return name if d.nil?

        # Remove domain prefix if present
        prefix = d.domain + "."
        if name.starts_with?(prefix)
          name = name[prefix.size..]
        end

        # Also check for lowercase domain (for cross-domain references that got prefixed)
        prefix_lower = d.domain.downcase + "."
        if name.starts_with?(prefix_lower)
          name = name[prefix_lower.size..]
        end

        name
      end

      # Add a file to the output
      private def add_file(path : String, content : String)
        @files[path] = content
      end
    end
  end
end
