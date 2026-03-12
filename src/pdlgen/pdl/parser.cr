require "regex"
require "./constants"

module Pdlgen
  module Pdl
    class Parser
      def parse(buf : Bytes) : PDL
        pdl = PDL.new

        # state objects
        domain = nil.as(Domain?)
        item = nil.as(Type?)
        subitems = nil.as(Array(Type)?)
        enumliterals = nil.as(Array(String)?)
        desc = ""
        copyright = false
        clear_desc = false

        lines = String.new(buf).lines

        lines.each_with_index do |line, i|
          # clear the description if toggled
          if clear_desc
            desc = ""
            clear_desc = false
          end

          # trim the line
          trimmed = line.strip

          # add to desc
          if trimmed.starts_with?('#')
            desc += "\n" unless desc.empty?
            desc += trimmed[1..].strip
            next
          else
            unless copyright
              copyright = true
              pdl.copyright = desc
            end
            clear_desc = true
          end

          # skip empty line
          next if trimmed.empty?

          # include
          if match = line.match(INCLUDE_RE)
            next
          end

          # domain
          if match = line.match(DOMAIN_RE)
            domain = Domain.new(
              domain: match[3],
              experimental: !match[1]?.nil?,
              deprecated: !match[2]?.nil?,
              description: desc.strip
            )
            pdl.domains << domain
            next
          end

          # dependencies
          if match = line.match(DEPENDS_RE)
            if domain
              domain.dependencies << match[1]
            end
            next
          end

          # type
          if match = line.match(TYPE_RE)
            if domain
              item = Type.new(
                raw_type: "type",
                raw_name: "#{domain.domain}.#{match[3]}",
                is_circular_dep: circular_dep?(domain.domain, match[3]),
                name: match[3],
                experimental: !match[1]?.nil?,
                deprecated: !match[2]?.nil?,
                description: desc.strip
              )
              assign_type(item, match[5], !match[4]?.nil?)
              domain.types << item
            end
            next
          end

          # command or event
          if match = line.match(COMMAND_EVENT_RE)
            if domain
              item = Type.new(
                raw_name: "#{domain.domain}.#{match[4]}",
                is_circular_dep: circular_dep?(domain.domain, match[4]),
                name: match[4],
                experimental: !match[1]?.nil?,
                deprecated: !match[2]?.nil?,
                description: desc.strip
              )
              if match[3] == "command"
                item.raw_type = "command"
                domain.commands << item
              else
                item.raw_type = "event"
                domain.events << item
              end
            end
            next
          end

          # member to params / returns / properties
          if match = line.match(MEMBER_RE)
            param = Type.new(
              raw_name: "#{domain.try &.domain || ""}.#{match[6]}",
              is_circular_dep: circular_dep?(domain.try &.domain || "", match[6]),
              name: match[6],
              experimental: !match[1]?.nil?,
              deprecated: !match[2]?.nil?,
              description: desc.strip,
              optional: !match[3]?.nil?
            )
            assign_type(param, match[5], !match[4]?.nil?)
            if match[5] == "enum"
              param.enum = [] of String
              enumliterals = param.enum
            end
            if subitems
              subitems << param
            end
            next
          end

          # parameters, returns, properties definition
          if match = line.match(PARAMS_RETS_PROPS_RE)
            current_item = item
            raise "line #{i + 1} has no current item for #{match[1]}" unless current_item
            case match[1]
            when "parameters"
              current_item.parameters = [] of Type
              subitems = current_item.parameters
            when "returns"
              current_item.returns = [] of Type
              subitems = current_item.returns
            when "properties"
              current_item.properties = [] of Type
              subitems = current_item.properties
            end
            next
          end

          # enum
          if line.match(ENUM_RE)
            current_item = item
            raise "line #{i + 1} has no current item for enum" unless current_item
            current_item.enum = [] of String
            enumliterals = current_item.enum
            next
          end

          # version
          if line.match(VERSION_RE)
            pdl.version = Version.new
            next
          end

          # version major
          if match = line.match(MAJOR_RE)
            version = pdl.version
            raise "line #{i + 1} has no version for major" unless version
            version.major = match[1].to_i
            next
          end

          # version minor
          if match = line.match(MINOR_RE)
            version = pdl.version
            raise "line #{i + 1} has no version for minor" unless version
            version.minor = match[1].to_i
            next
          end

          # redirect
          if match = line.match(REDIRECT_RE)
            current_item = item
            raise "line #{i + 1} has no current item for redirect" unless current_item
            current_item.redirect = Redirect.new(match[1], "")
            if desc_match = desc.match(REDIRECT_COMMENT_RE)
              name = desc_match[1]
              if idx = name.rindex('.')
                name = name[idx + 1..]
              end
              redirect = current_item.redirect
              raise "line #{i + 1} has no redirect object" unless redirect
              redirect.name = name
            end
            next
          end

          # enum literal
          if line.match(ENUM_LITERAL_RE)
            literals = enumliterals
            raise "line #{i + 1} has no enum target" unless literals
            literals << trimmed
            next
          end

          raise "line #{i + 1} unknown token #{line.inspect}"
        end

        pdl
      end

      private def assign_type(item : Type, typ : String, is_array : Bool)
        if is_array
          item.type = TypeEnum::Array
          item.items = Type.new
          nested = item.items
          raise "missing nested type for array assignment" unless nested
          assign_type(nested, typ, false)
          return
        end

        typ = "string" if typ == "enum"

        # Normalize primitive type names to lowercase
        normalized_typ = typ.downcase
        if primitive = PRIMITIVE_TYPES[normalized_typ]?
          item.type = primitive
        else
          item.ref = typ
        end
      end

      private def circular_dep?(dtyp : String, typ : String) : Bool
        Pdl.circular_dep?(dtyp, typ)
      end
    end
  end
end
