require "./pdl/parser"
require "./pdl/har"
require "file"

module Pdlgen
  module Pdl
    # PDL contains information about the domains, types, commands, and events of
    # the Chrome DevTools Protocol.
    class PDL
      include JSON::Serializable

      property copyright : String
      property version : Version?
      property domains : Array(Domain)

      def initialize(@copyright = "", @version = nil, @domains = [] of Domain)
      end

      # Returns the PDL as bytes (for writing to file)
      def bytes : Bytes
        io = IO::Memory.new
        to_pdl(io)
        io.to_s.to_slice
      end

      # Writes the PDL in text format to the given IO
      private def to_pdl(io : IO) : Nil
        # Helper functions
        write_desc = ->(desc : String, indent : String) do
          return if desc.empty?
          desc.each_line do |line|
            if line.empty?
              io << indent << "#\n"
            else
              io << indent << "# " << line << "\n"
            end
          end
        end

        write_decl = ->(typ : String, name : String, desc : String, indent : String, experimental : Bool, deprecated : Bool, optional : Bool, extra : Array(String)) do
          write_desc.call(desc, indent)
          parts = [] of String
          parts << "experimental" if experimental
          parts << "deprecated" if deprecated
          parts << "optional" if optional
          parts << typ
          parts << name
          parts.concat(extra)
          io << indent << parts.join(" ") << "\n"
        end

        write_redirect = ->(typ : Type, indent : String) do
          return unless typ.redirect
          r = typ.redirect.not_nil!
          if !r.name.empty?
            io << indent << "# Use '" << r.domain << "." << r.name << "' instead\n"
          end
          io << indent << "redirect " << r.domain << "\n"
        end

        write_props = ->(typ : String, indent : String, props : Array(Type)) do
          return if props.empty?
          io << indent << typ << "\n"
          props.each do |p|
            ref = p.type.to_s
            if !p.ref.empty?
              ref = p.ref
            end
            if p.type == TypeEnum::Array
              ref = p.items.not_nil!.ref
              if ref.empty?
                ref = p.items.not_nil!.type.to_s
              end
              ref = "array of " + ref
            end
            if p.enum && !p.enum.not_nil!.empty?
              ref = "enum"
            end
            write_decl.call(ref, p.name, p.description, indent + "  ",
              p.experimental, p.deprecated, p.optional, [] of String)
            if p.enum && !p.enum.not_nil!.empty?
              p.enum.not_nil!.each do |e|
                io << indent << "    " << e << "\n"
              end
            end
          end
        end

        # Add copyright
        if !copyright.empty?
          write_desc.call(copyright, "")
          io << "\n"
        end

        # Add version
        if version = @version
          io << "version\n"
          io << "  major " << version.major << "\n"
          io << "  minor " << version.minor << "\n"
          io << "\n"
        end

        # Copy and sort domains
        domains = @domains.dup
        domains.sort_by!(&.domain)

        # Write each domain
        domains.each do |d|
          # Write domain stanza
          write_decl.call("domain", d.domain, d.description, "", d.experimental, d.deprecated, false, [] of String)

          # Write depends
          d.dependencies.each do |dep|
            io << "  depends on " << dep << "\n"
          end
          io << "\n"

          # Sort types
          types = d.types.dup
          types.sort_by!(&.name)

          # Write types
          types.each do |typ|
            extends = typ.type.to_s
            if typ.type == TypeEnum::Array
              if typ.items
                extends = typ.items.not_nil!.type.to_s
                if extends.empty?
                  extends = typ.items.not_nil!.ref
                end
                extends = "array of " + extends
              end
            end
            write_decl.call("type", typ.name, typ.description, "  ",
              typ.experimental, typ.deprecated, typ.optional, ["extends", extends])
            write_redirect.call(typ, "  ")
            if typ.enum && !typ.enum.not_nil!.empty?
              io << "    enum\n"
              typ.enum.not_nil!.each do |e|
                io << "     " << e << "\n"
              end
            end
            write_props.call("properties", "    ", typ.properties)
            io << "\n"
          end

          # Sort commands
          commands = d.commands.dup
          commands.sort_by!(&.name)

          # Write commands
          commands.each do |c|
            write_decl.call("command", c.name, c.description, "  ",
              c.experimental, c.deprecated, c.optional, [] of String)
            write_redirect.call(c, "    ")
            write_props.call("parameters", "    ", c.parameters)
            write_props.call("returns", "    ", c.returns)
            io << "\n"
          end

          # Sort events
          events = d.events.dup
          events.sort_by!(&.name)

          # Write events
          events.each do |e|
            write_decl.call("event", e.name, e.description, "  ",
              e.experimental, e.deprecated, e.optional, [] of String)
            write_redirect.call(e, "    ")
            write_props.call("parameters", "    ", e.parameters)
            io << "\n"
          end
        end

        # Trim trailing whitespace and ensure newline at end
        # (handled by IO)
      end
    end

    # Version contains version information.
    class Version
      include JSON::Serializable

      property major : Int32
      property minor : Int32

      def initialize(@major = 0, @minor = 0)
      end
    end

    # Domain represents a Chrome DevTools Protocol domain.
    class Domain
      include JSON::Serializable

      property domain : String
      property description : String
      property experimental : Bool
      property deprecated : Bool
      property dependencies : Array(String)
      property types : Array(Type)
      property commands : Array(Type)
      property events : Array(Type)

      def initialize(@domain, @description = "", @experimental = false, @deprecated = false,
                     @dependencies = [] of String, @types = [] of Type, @commands = [] of Type,
                     @events = [] of Type)
      end
    end

    # Type represents a Chrome DevTools Protocol type.
    class Type
      include JSON::Serializable

      property type : TypeEnum
      property name : String
      property description : String
      property experimental : Bool
      property deprecated : Bool
      property optional : Bool
      property ref : String

      @[JSON::Field(ignore_serialize: true)]
      property items : Type?

      @[JSON::Field(ignore_serialize: true)]
      property parameters : Array(Type)

      @[JSON::Field(ignore_serialize: true)]
      property returns : Array(Type)

      @[JSON::Field(ignore_serialize: true)]
      property properties : Array(Type)

      property redirect : Redirect?
      property enum : Array(String)?

      # Additional fields
      property raw_type : String
      property raw_name : String
      property raw_see : String
      property timestamp_type : TimestampType
      property is_circular_dep : Bool
      property no_expose : Bool
      property no_resolve : Bool
      property always_emit : Bool

      @[JSON::Field(ignore_serialize: true)]
      property enum_value_name_map : Hash(String, String)

      property enum_bit_mask : Bool
      property extra : String

      def initialize(@type = TypeEnum::Any, @name = "", @description = "", @experimental = false,
                     @deprecated = false, @optional = false, @ref = "", @items = nil,
                     @parameters = [] of Type, @returns = [] of Type, @properties = [] of Type,
                     @redirect = nil, @enum = nil, @raw_type = "", @raw_name = "",
                     @raw_see = "", @timestamp_type = TimestampType::Millisecond,
                     @is_circular_dep = false, @no_expose = false, @no_resolve = false,
                     @always_emit = false, @enum_value_name_map = Hash(String, String).new,
                     @enum_bit_mask = false, @extra = "")
      end
    end

    # TypeEnum is the Chrome domain type enum.
    enum TypeEnum
      Any
      Array
      Binary
      Boolean
      Integer
      Number
      Object
      String
      Timestamp

      def to_s(io : IO) : Nil
        case self
        when Any       then io << "any"
        when Array     then io << "array"
        when Binary    then io << "binary"
        when Boolean   then io << "boolean"
        when Integer   then io << "integer"
        when Number    then io << "number"
        when Object    then io << "object"
        when String    then io << "string"
        when Timestamp then io << "timestamp"
        end
      end
    end

    # TimestampType are the various timestamp subtypes.
    enum TimestampType
      Millisecond
      Second
      Monotonic
    end

    # Redirect represents a type redirect.
    class Redirect
      include JSON::Serializable

      property domain : String
      property name : String

      def initialize(@domain, @name)
      end

      def to_s : String
        if name.empty?
          domain
        else
          "#{domain}.#{name}"
        end
      end
    end

    # Parse parses a PDL file contained in buf.
    def self.parse(buf : Bytes) : PDL
      Parser.new.parse(buf)
    end

    # LoadFile loads a PDL file from the specified filename.
    def self.load_file(filename : String) : PDL
      parse(File.read(filename).to_slice)
    end

    # Combine combines domains from multiple PDL definitions into a single PDL.
    def self.combine(pdls : Array(PDL)) : PDL
      pdl = PDL.new
      pdls.each do |p|
        if pdl.copyright.empty?
          pdl.copyright = p.copyright
        end
        if pdl.version.nil?
          pdl.version = Version.new
        end
        if p.version
          if pdl.version.not_nil!.major < p.version.not_nil!.major
            pdl.version.not_nil!.major = p.version.not_nil!.major
            pdl.version.not_nil!.minor = p.version.not_nil!.minor
          elsif pdl.version.not_nil!.minor < p.version.not_nil!.minor
            pdl.version.not_nil!.minor = p.version.not_nil!.minor
          end
        end
        pdl.domains.concat(p.domains)
      end
      pdl
    end
  end
end
