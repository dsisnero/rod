module Pdlgen
  module Gen
    module CrystalUtil
      # Prefix and suffix values.
      TYPE_PREFIX            = ""
      TYPE_SUFFIX            = ""
      EVENT_METHOD_PREFIX    = "Event"
      EVENT_METHOD_SUFFIX    = ""
      COMMAND_METHOD_PREFIX  = "Command"
      COMMAND_METHOD_SUFFIX  = ""
      EVENT_TYPE_PREFIX      = "Event"
      EVENT_TYPE_SUFFIX      = ""
      COMMAND_TYPE_PREFIX    = ""
      COMMAND_TYPE_SUFFIX    = ""
      COMMAND_RETURNS_PREFIX = ""
      COMMAND_RETURNS_SUFFIX = "Result"
      OPTION_FUNC_PREFIX     = "With"
      OPTION_FUNC_SUFFIX     = ""

      # Base64EncodedParamName is the base64encoded variable name in command
      # return values when they are optionally base64 encoded.
      BASE64_ENCODED_PARAM_NAME = "base64Encoded"

      # Base64EncodedDescriptionPrefix is the prefix for command return
      # description prefix when base64 encoded.
      BASE64_ENCODED_DESCRIPTION_PREFIX = "Base64-encoded"

      # ChromeDevToolsDocBase is the base URL for the Chrome DevTools
      # documentation site.
      #
      # tot is "tip-of-tree"
      CHROME_DEV_TOOLS_DOC_BASE = "https://chromedevtools.github.io/devtools-protocol/tot"

      # ProtoName returns the protocol name of the type.
      def self.proto_name(t : Pdl::Type, d : Pdl::Domain?) : String
        prefix = d ? d.domain + "." : ""
        prefix + t.name
      end

      # CamelName returns the CamelCase name of the type.
      def self.camel_name(t : Pdl::Type) : String
        t.name.camelcase
      end

      # EventMethodType returns the method type of the event.
      def self.event_method_type(t : Pdl::Type, d : Pdl::Domain?) : String
        EVENT_METHOD_PREFIX + proto_name(t, d).camelcase + EVENT_METHOD_SUFFIX
      end

      # CommandMethodType returns the method type of the event.
      def self.command_method_type(t : Pdl::Type, d : Pdl::Domain?) : String
        COMMAND_METHOD_PREFIX + proto_name(t, d).camelcase + COMMAND_METHOD_SUFFIX
      end

      # TypeName returns the type name using the supplied prefix and suffix.
      def self.type_name(t : Pdl::Type, prefix, suffix : String) : String
        prefix + camel_name(t) + suffix
      end

      # EventType returns the type of the event.
      def self.event_type(t : Pdl::Type) : String
        type_name(t, EVENT_TYPE_PREFIX, EVENT_TYPE_SUFFIX)
      end

      # CommandType returns the type of the command.
      def self.command_type(t : Pdl::Type) : String
        type_name(t, COMMAND_TYPE_PREFIX, COMMAND_TYPE_SUFFIX)
      end

      # CommandReturnsType returns the type of the command return type.
      def self.command_returns_type(t : Pdl::Type) : String
        type_name(t, COMMAND_RETURNS_PREFIX, COMMAND_RETURNS_SUFFIX)
      end

      # ResolveRef resolves a type reference across domains.
      def self.resolve_ref(t : Pdl::Type, d : Pdl::Domain, domains : Array(Pdl::Domain)) : Tuple(String, Pdl::Type)
        n = t.ref.split('.', 2)

        # determine domain
        dtyp = d.domain
        typ = n[0]
        if n.size == 2
          dtyp = n[0]
          typ = n[1]
        end
        ref = (dtyp + "." + typ).downcase
        short_ref = typ.downcase

        # DEBUG
        # puts "DEBUG resolve_ref: t.ref=#{t.ref}, d.domain=#{d.domain}, dtyp=#{dtyp}, typ=#{typ}, ref=#{ref}"

        # determine if ref points to an object
        resolved = nil
        domains.each do |domain_iter|
          if dtyp == domain_iter.domain
            domain_iter.types.each do |type_iter|
              if domain_iter.domain == "cdp" && short_ref == type_iter.raw_name.split('.', 2)[1].downcase
                resolved = type_iter
                break
              elsif ref == type_iter.raw_name.downcase
                resolved = type_iter
                break
              end
            end
            break
          end
        end

        if resolved.nil?
          raise "could not resolve type #{ref} in domain #{d.domain}"
        end

        {dtyp, resolved}
      end

      # ResolveType resolves the type relative to the Crystal domain.
      #
      # Returns the domain of the underlying type, the underlying type (or the
      # original passed type if not a reference) and the fully qualified type name.
      def self.resolve_type(t : Pdl::Type, d : Pdl::Domain, domains : Array(Pdl::Domain)) : Tuple(String, Pdl::Type, String)
        if t.no_expose? || t.no_resolve? || t.ref.starts_with?("*")
          return {d.domain, t, t.ref}
        end

        if !t.ref.empty?
          dtyp, typ = resolve_ref(t, d, domains)

          # add prefix if is a type defined as having circular dependency issues
          s = ""
          if typ.is_circular_dep? && d.domain != "cdp"
            s = "Cdp::"
          elsif dtyp != d.domain
            s = "Cdp::" + dtyp.camelcase + "::"
          end

          # add reference
          type_name = typ.name.camelcase
          # Remove domain prefix if already present in type name
          prefix = dtyp + "."
          if type_name.starts_with?(prefix)
            type_name = type_name[prefix.size..]
          end
          # Also check lowercase prefix
          prefix_lower = dtyp.downcase + "."
          if type_name.starts_with?(prefix_lower)
            type_name = type_name[prefix_lower.size..]
          end
          return {dtyp, typ, s + type_name}
        end

        if t.type == Pdl::TypeEnum::Array
          if items = t.items
            dtyp, typ, z = resolve_type(items, d, domains)
            return {dtyp, typ, "Array(#{z})"}
          else
            raise "Array type missing items"
          end
        end

        if t.type == Pdl::TypeEnum::Object && (t.properties.nil? || t.properties.empty?)
          return {d.domain, t, crystal_enum_type(Pdl::TypeEnum::Any)}
        end

        if t.type == Pdl::TypeEnum::Object
          raise "should not encounter an object with defined properties that does not have Ref and Name"
        end

        {d.domain, t, crystal_enum_type(t.type)}
      end

      # CrystalType returns the Crystal type for the type.
      def self.crystal_type(t : Pdl::Type, d : Pdl::Domain, domains : Array(Pdl::Domain)) : String
        _, _, z = resolve_type(t, d, domains)
        z
      end

      # CrystalEnumType returns the Crystal type for the TypeEnum.
      def self.crystal_enum_type(te : Pdl::TypeEnum) : String
        case te
        when Pdl::TypeEnum::Any
          "JSON::Any"
        when Pdl::TypeEnum::Boolean
          "Bool"
        when Pdl::TypeEnum::Integer
          "Int64"
        when Pdl::TypeEnum::Number
          "Float64"
        when Pdl::TypeEnum::String, Pdl::TypeEnum::Binary
          "String"
        when Pdl::TypeEnum::Timestamp
          "Time"
        else
          raise "called CrystalEnumType on non primitive type #{te}"
        end
      end

      # PackageName returns the package name to use for a domain.
      def self.package_name(d : Pdl::Domain) : String
        d.domain.downcase
      end
    end
  end
end
