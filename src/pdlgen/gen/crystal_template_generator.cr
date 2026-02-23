require "ecr/macros"
require "../pdl"
require "../fixup"
require "./crystal_util"

module Pdlgen
  module Gen
    # CrystalTemplateGenerator generates Crystal source code using ECR templates.
    class CrystalTemplateGenerator < Emitter
      getter files : Hash(String, String)

      # ECR embedded templates - will be generated at compile time
      # Note: ECR macros are used in the render methods below

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
        domains.each do |domain|
          # Skip deprecated domains
          next if domain.deprecated?

          # Collect referenced domains for this domain
          referenced_domains = collect_referenced_domains(domain, domains)

          # Generate main domain file
          domain_content = render_domain_module(domain, domains, base_pkg, referenced_domains)
          pkg_name = CrystalUtil.package_name(domain)
          add_file("#{pkg_name}/#{pkg_name}.cr", domain_content)

          # Generate domain types file if there are types
          if !domain.types.empty?
            types_content = render_domain_types(domain, domains, base_pkg, referenced_domains)
            add_file("#{pkg_name}/types.cr", types_content)
          end

          # Generate domain events file if there are events
          if !domain.events.empty?
            events_content = render_domain_events(domain, domains, base_pkg, referenced_domains)
            add_file("#{pkg_name}/events.cr", events_content)
          end
        end
      end

      private def generate_shared_types(domains : Array(Pdl::Domain), base_pkg : String)
        # Find circular dependency types, deduplicate by raw_name
        unique_types = Hash(String, Pdl::Type).new
        domains.each do |domain|
          domain.types.each do |type|
            if type.is_circular_dep?
              unique_types[type.raw_name] = type
            end
          end
        end

        typs = unique_types.values

        content = String.build do |io|
          io << "# Shared Chrome DevTools Protocol Domain types.\n"
          io << "module Cdp\n"
          typs.each do |type|
            generate_type_struct(io, type, nil, domains)
          end
          io << "end\n"
        end

        add_file("cdp/types.cr", content)
      end

      private def generate_root_package(domains : Array(Pdl::Domain), base_pkg : String)
        content = render_root_module(base_pkg)
        add_file("cdp.cr", content)
      end

      private def collect_referenced_domains(domain : Pdl::Domain, domains : Array(Pdl::Domain)) : Array(String)
        referenced = Set(String).new

        # Check types
        domain.types.each do |type|
          collect_references_from_type(type, domain, domains, referenced)
        end

        # Check commands
        domain.commands.each do |command|
          command.parameters.each do |param|
            collect_references_from_type(param, domain, domains, referenced)
          end
          command.returns.each do |return_param|
            collect_references_from_type(return_param, domain, domains, referenced)
          end
        end

        # Check events
        domain.events.each do |event|
          event.parameters.each do |param|
            collect_references_from_type(param, domain, domains, referenced)
          end
        end

        referenced.to_a
      end

      private def collect_references_from_type(type : Pdl::Type, domain : Pdl::Domain, domains : Array(Pdl::Domain), referenced : Set(String))
        # Process this type's reference
        if !type.ref.empty?
          # Parse ref to get domain
          n = type.ref.split('.', 2)
          ref_domain = n[0]

          # Check if it's a different domain
          if ref_domain != domain.domain && domains.any? { |dom| dom.domain == ref_domain }
            referenced << ref_domain.downcase
          end
        end

        # Check array items
        if type.type == Pdl::TypeEnum::Array && (items = type.items)
          collect_references_from_type(items, domain, domains, referenced)
        end

        # Check properties (for object types)
        if type.properties && !type.properties.empty?
          type.properties.each do |prop|
            collect_references_from_type(prop, domain, domains, referenced)
          end
        end

        # Check parameters (for commands and events)
        if type.parameters && !type.parameters.empty?
          type.parameters.each do |param|
            collect_references_from_type(param, domain, domains, referenced)
          end
        end

        # Check returns (for commands)
        if type.returns && !type.returns.empty?
          type.returns.each do |ret|
            collect_references_from_type(ret, domain, domains, referenced)
          end
        end
      end

      # Template rendering methods
      private def render_root_module(base_pkg : String) : String
        ECR.render "src/pdlgen/gen/crystal_templates/root.ecr"
      end

      private def render_domain_module(d : Pdl::Domain, domains : Array(Pdl::Domain), base_pkg : String, referenced_domains : Array(String)) : String
        ECR.render "src/pdlgen/gen/crystal_templates/domain_module.ecr"
      end

      private def render_domain_types(d : Pdl::Domain, domains : Array(Pdl::Domain), base_pkg : String, referenced_domains : Array(String)) : String
        ECR.render "src/pdlgen/gen/crystal_templates/domain_types.ecr"
      end

      private def render_domain_events(d : Pdl::Domain, domains : Array(Pdl::Domain), base_pkg : String, referenced_domains : Array(String)) : String
        ECR.render "src/pdlgen/gen/crystal_templates/domain_events.ecr"
      end

      # Helper methods for templates
      private def crystal_type(t : Pdl::Type, d : Pdl::Domain, domains : Array(Pdl::Domain)) : String
        CrystalUtil.crystal_type(t, d, domains)
      end

      private def command_type(c : Pdl::Type) : String
        CrystalUtil.command_type(c)
      end

      private def command_returns_type(c : Pdl::Type) : String
        CrystalUtil.command_returns_type(c)
      end

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

      private def enum_member_name(value : String) : String
        # Convert string like "all-screens-capture" or "Render process gone." to "AllScreensCapture" or "RenderProcessGone"
        # Replace any non-alphanumeric characters with space, split by whitespace, camelcase each part, and join
        cleaned = value.gsub(/[^a-zA-Z0-9]/, " ")
        parts = cleaned.split(/\s+/).reject(&.empty?)
        parts.map(&.camelcase).join
      end

      private def bool_type?(type_str : String) : Bool
        type_str == "Bool"
      end

      private def safe_constant_name(name : String) : String
        case name
        when "Object"
          "ObjectType"
        when "String"
          "StringType"
        when "Symbol"
          "SymbolType"
        when "Number"
          "NumberType"
        when "Boolean"
          "BooleanType"
        when "Function"
          "FunctionType"
        when "Undefined"
          "Undefined"
        else
          name
        end
      end

      private def safe_enum_member_name(value : String) : String
        safe_constant_name(enum_member_name(value))
      end

      private def string_enum_constant_name(t : Pdl::Type, value : String, d : Pdl::Domain?) : String
        # Generate a unique constant name for string enum values
        # Use the type name (without domain prefix) + the enum member name
        prefix = type_name_for_domain(t, d)
        member = safe_enum_member_name(value)
        "#{prefix}#{member}"
      end

      private def generate_type_struct(io : IO, t : Pdl::Type, d : Pdl::Domain?, domains : Array(Pdl::Domain))
        if t.deprecated?
          io << "  @[Deprecated]\n"
        end
        if t.experimental?
          io << "  @[Experimental]\n"
        end

        case t.type
        when Pdl::TypeEnum::Object
          if (enum_values = t.enum) && !enum_values.empty?
            # Enum type
            io << "  enum #{type_name_for_domain(t, d)}\n"
            enum_values.each do |value|
              io << "    #{safe_constant_name(value.camelcase)}\n"
            end
            io << "  end\n"
          else
            # Struct type
            io << "  struct #{type_name_for_domain(t, d)}\n"
            io << "    include JSON::Serializable\n\n"
            if t.properties && !t.properties.empty?
              t.properties.each do |property|
                next if property.deprecated? && !property.always_emit?
                next if property.name.empty?

                type_str = d ? CrystalUtil.crystal_type(property, d, domains) : "JSON::Any"
                if property.optional?
                  io << "    @[JSON::Field(emit_null: false)]\n"
                end
                if bool_type?(type_str)
                  io << "    property? #{property.name.underscore} : #{type_str}"
                else
                  io << "    property #{property.name.underscore} : #{type_str}"
                end
                io << "?" if property.optional?
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

      private def add_file(path : String, content : String)
        @files[path] = content
      end
    end
  end
end
