require "./pdl"
require "./gen/crystal_extras"

module Pdlgen
  module Fixup
    # Specific type names to use for the applied fixes to the protocol domains.
    #
    # These need to be here in case the location of these types change (see above)
    # relative to the generated 'cdp' package.
    DOM_NODE_ID_REF = "DOM::NodeId"
    DOM_NODE_REF    = "DOM::Node?"

    AX_RE = /^AX/

    # FixDomains modifies, updates, alters, fixes, and adds to the types defined
    # in the domains, so that the generated Chrome DevTools Protocol domain code
    # is more Crystal-like and easier to use.
    #
    # Please see package-level documentation for the list of changes made to the
    # various domains.
    def self.fix_domains(domains : Array(Pdl::Domain))
      # process domains
      domains.each do |domain|
        case domain.domain
        when "CSS"
          domain.types.each do |typ|
            if typ.name == "CSSComputedStyleProperty"
              typ.name = "ComputedProperty"
            end
          end
        when "DOM"
          # add DOM types
          domain.types << Pdl::Type.new(
            raw_name: "DOM.NodeType",
            raw_see: "https://developer.mozilla.org/en/docs/Web/API/Node/nodeType",
            is_circular_dep: true,
            name: "NodeType",
            type: Pdl::TypeEnum::Integer,
            description: "Node type.",
            enum: [
              "Element", "Attribute", "Text", "CDATA", "EntityReference",
              "Entity", "ProcessingInstruction", "Comment", "Document",
              "DocumentType", "DocumentFragment", "Notation",
            ]
          )

          domain.types.each do |type|
            case type.name
            when "NodeId", "BackendNodeId"
              type.raw_name = domain.domain + "." + type.name
              # TODO: add extra for unmarshaler
              # type.extra += gotpl.ExtraFixStringUnmarshaler(snaker.ForceCamelIdentifier(type.name), "ParseInt", ", 10, 64")

            when "Node"
              type.properties.concat([
                Pdl::Type.new(
                  name: "Parent",
                  ref: DOM_NODE_REF,
                  description: "Parent node.",
                  no_resolve: true,
                  no_expose: true
                ),
                Pdl::Type.new(
                  name: "Invalidated",
                  ref: "Channel(Nil)",
                  description: "Invalidated channel.",
                  no_resolve: true,
                  no_expose: true
                ),
                Pdl::Type.new(
                  name: "State",
                  ref: "NodeState",
                  description: "Node state.",
                  no_resolve: true,
                  no_expose: true
                ),
                Pdl::Type.new(
                  name: "mutex",
                  ref: "Mutex",
                  description: "Read write mutex.",
                  no_resolve: true,
                  no_expose: true
                ),
              ])
              # TODO: add extra node template
              type.extra += Gen::CrystalExtras.extra_node_template
            when "RGBA"
              type.properties.each do |prop|
                case prop.name
                when "a"
                  prop.always_emit = true
                end
              end
            end
          end
        when "Input"
          # Find or create Modifier type
          modifier_type = domain.types.find { |type| type.name == "Modifier" }
          if modifier_type
            # Update existing Modifier type
            modifier_type.raw_name = "Input.Modifier"
            modifier_type.raw_see = "https://chromedevtools.github.io/devtools-protocol/tot/Input#method-dispatchKeyEvent"
            modifier_type.type = Pdl::TypeEnum::Integer
            modifier_type.enum_bit_mask = true
            modifier_type.description = "Input key modifier type."
            modifier_type.enum = ["None", "Alt", "Ctrl", "Meta", "Shift"]
            modifier_type.extra = "# ModifierCommand is an alias for ModifierMeta.\nModifierCommand = Modifier::Meta\n"
          else
            # add Input types
            domain.types << Pdl::Type.new(
              raw_name: "Input.Modifier",
              raw_see: "https://chromedevtools.github.io/devtools-protocol/tot/Input#method-dispatchKeyEvent",
              name: "Modifier",
              type: Pdl::TypeEnum::Integer,
              enum_bit_mask: true,
              description: "Input key modifier type.",
              enum: ["None", "Alt", "Ctrl", "Meta", "Shift"],
              extra: "# ModifierCommand is an alias for ModifierMeta.\nModifierCommand = Modifier::Meta\n"
            )
          end

          domain.types.each do |typ|
            case typ.name
            when "GestureSourceType"
              typ.name = "GestureType"
            when "TimeSinceEpoch"
              typ.type = Pdl::TypeEnum::Timestamp
              typ.timestamp_type = Pdl::TimestampType::Second
              # TODO: add extra timestamp template
              # typ.extra += gotpl.ExtraTimestampTemplate(typ, domain)
            end
          end

          domain.commands.each do |cmd|
            case cmd.name
            when "dispatchKeyEvent"
              cmd.parameters.each do |param|
                case param.name
                when "autoRepeat", "isKeypad", "isSystemKey"
                  param.always_emit = true
                end
              end
            end
          end
        when "Inspector"
          # add Inspector types
          domain.types << Pdl::Type.new(
            raw_name: "Inspector.DetachReason",
            raw_see: "( -- none -- )",
            name: "DetachReason",
            type: Pdl::TypeEnum::String,
            enum: ["target_closed", "canceled_by_user", "replaced_with_devtools", "Render process gone."],
            description: "Detach reason."
          )

          # find detached event's reason parameter and change type
          domain.events.each do |event|
            if event.name == "detached"
              event.parameters.each do |param|
                if param.name == "reason"
                  param.ref = "DetachReason"
                  param.type = Pdl::TypeEnum::Any
                  break
                end
              end
              break
            end
          end
        when "Network"
          domain.types.each do |typ|
            # change Monotonic to TypeTimestamp and add extra unmarshaling template
            if typ.name == "TimeSinceEpoch"
              typ.type = Pdl::TypeEnum::Timestamp
              typ.timestamp_type = Pdl::TimestampType::Second
              # TODO: add extra timestamp template
              typ.extra += Gen::CrystalExtras.extra_timestamp_template(typ, domain)
            end

            # change Monotonic to TypeTimestamp and add extra unmarshaling template
            if typ.name == "MonotonicTime"
              typ.type = Pdl::TypeEnum::Timestamp
              typ.timestamp_type = Pdl::TimestampType::Second
              # TODO: add extra timestamp template
              typ.extra += Gen::CrystalExtras.extra_timestamp_template(typ, domain)
            end

            # change Headers to be a Hash(String, JSON::Any)
            if typ.name == "Headers"
              typ.type = Pdl::TypeEnum::Any
              typ.ref = "Hash(String, JSON::Any)"
            end
          end
        when "Page"
          domain.types.each do |typ|
            case typ.name
            when "FrameId"
              # TODO: add extra unmarshaler
              # typ.extra += gotpl.ExtraFixStringUnmarshaler(snaker.ForceCamelIdentifier(typ.name), "", "")

            when "Frame"
              typ.properties.concat([
                Pdl::Type.new(
                  name: "State",
                  ref: "FrameState",
                  description: "Frame state.",
                  no_resolve: true,
                  no_expose: true
                ),
                Pdl::Type.new(
                  name: "Root",
                  ref: DOM_NODE_REF,
                  description: "Frame document root.",
                  no_resolve: true,
                  no_expose: true
                ),
                Pdl::Type.new(
                  name: "Nodes",
                  ref: "Hash(#{DOM_NODE_ID_REF}, #{DOM_NODE_REF})",
                  description: "Frame nodes.",
                  no_resolve: true,
                  no_expose: true
                ),
                Pdl::Type.new(
                  name: "mutex",
                  ref: "Mutex",
                  description: "Read write mutex.",
                  no_resolve: true,
                  no_expose: true
                ),
              ])
              # TODO: add extra frame template
              typ.extra += Gen::CrystalExtras.extra_frame_template

              # convert Frame.id/parentId to $ref of FrameID
              typ.properties.each do |prop|
                if prop.name == "id" || prop.name == "parentId"
                  prop.ref = "FrameId"
                  prop.type = Pdl::TypeEnum::Any
                end
              end
            end
          end

          domain.commands.each do |cmd|
            case cmd.name
            when "printToPDF"
              cmd.parameters.each do |param|
                case param.name
                when "marginTop", "marginBottom", "marginLeft", "marginRight"
                  param.always_emit = true
                end
              end
            end
          end
        when "Runtime"
          typs = [] of Pdl::Type
          domain.types.each do |typ|
            case typ.name
            when "Timestamp"
              typ.type = Pdl::TypeEnum::Timestamp
              typ.timestamp_type = Pdl::TimestampType::Millisecond
              # TODO: add extra timestamp template
              typ.extra += Gen::CrystalExtras.extra_timestamp_template(typ, domain)
            when "ExceptionDetails"
              typ.extra += %(# Error satisfies the error interface.
  def error : String
    String.build do |b|
      # TODO: watch script parsed events and match the ExceptionDetails.ScriptID
      # to the name/location of the actual code and display here
      b << "exception "
      b.inspect(e.text)
      b << " ("
      b << e.line_number
      b << ":"
      b << e.column_number
      b << ")"
      if obj = e.exception
        b << ": "
        b << obj.description
      end
    end
  end
)
            end
            typs << typ
          end
          domain.types = typs
        end

        # convert object properties
        domain.types.each do |typ|
          if typ.properties
            typ.properties = convert_object_properties(typ.properties, typ, domain, typ.name)
          end
        end

        # process events and commands
        convert_objects(domain, domain.events)
        convert_objects(domain, domain.commands)

        # fix input enums
        if domain.domain == "Input"
          domain.types.each do |typ|
            if (enum_vals = typ.enum) && typ.name != "Modifier"
              typ.enum_value_name_map = Hash(String, String).new
              enum_vals.each do |value|
                prefix = ""
                case typ.name
                when "GestureType"
                  prefix = "Gesture"
                when "ButtonType"
                  prefix = "Button"
                end
                n = prefix + snaker_force_camel_identifier(value)
                if typ.name == "KeyType"
                  n = "Key" + n.gsub("Key", "")
                end
                n = n.gsub("Cancell", "Cancel")
                typ.enum_value_name_map[value] = n
              end
            end
          end
        end

        # fix type stuttering
        domain.types.each do |typ|
          if !typ.no_expose? && !typ.no_resolve? && !typ.is_circular_dep?
            name = typ.raw_name.sub(/^#{Regex.escape(domain.domain)}\\.?/, "")
            if typ.raw_name.starts_with?("Accessibility.")
              name = typ.raw_name.sub(/^Accessibility\./, "").gsub(AX_RE, "")
            end
            if typ.name != name && name != ""
              typ.name = name
            end
          end
        end

        # Deduplicate types by name within domain
        unique_types = Hash(String, Pdl::Type).new
        domain.types.each do |typ|
          unique_types[typ.name] = typ
        end
        domain.types = unique_types.values
      end
    end

    # convertObjects converts the Parameters and Returns properties of the object
    # types.
    private def self.convert_objects(d : Pdl::Domain, typs : Array(Pdl::Type))
      typs.each do |typ|
        typ.parameters = convert_object_properties(typ.parameters, typ, d, typ.name)
        if typ.returns
          typ.returns = convert_object_properties(typ.returns, typ, d, typ.name)
        end
      end
    end

    # convertObjectProperties converts object properties.
    private def self.convert_object_properties(params : Array(Pdl::Type), parent : Pdl::Type, d : Pdl::Domain, name : String) : Array(Pdl::Type)
      r = [] of Pdl::Type
      params.each do |param|
        if items = param.items
          r << Pdl::Type.new(
            raw_type: param.raw_type,
            raw_name: param.raw_name,
            is_circular_dep: param.is_circular_dep?,
            name: param.name,
            type: Pdl::TypeEnum::Array,
            description: param.description,
            optional: param.optional?,
            always_emit: param.always_emit?,
            items: convert_object_properties([items], parent, d, name + "." + param.name)[0]
          )
        elsif (enum_vals = param.enum) && !enum_vals.empty?
          r << fixup_enum_parameter(name, param, parent, d)
        elsif param.name == "modifiers"
          r << Pdl::Type.new(
            raw_type: param.raw_type,
            raw_name: param.raw_name,
            is_circular_dep: param.is_circular_dep?,
            name: param.name,
            ref: "Modifier",
            description: param.description,
            optional: param.optional?,
            always_emit: true
          )
        elsif param.name == "nodeType"
          r << Pdl::Type.new(
            raw_type: param.raw_type,
            raw_name: param.raw_name.sub("nodeType", "NodeType"),
            is_circular_dep: param.is_circular_dep?,
            name: param.name,
            ref: "DOM.NodeType",
            description: param.description,
            optional: param.optional?,
            always_emit: param.always_emit?
          )
        elsif !param.ref.empty? && !param.no_expose? && !param.no_resolve?
          r << Pdl::Type.new(
            raw_name: param.raw_name.sub("nodeType", "NodeType"),
            is_circular_dep: param.is_circular_dep?,
            name: param.name,
            ref: "DOM.NodeType",
            description: param.description,
            optional: param.optional?,
            always_emit: param.always_emit?
          )
        else
          r << param
        end
      end
      r
    end

    # addEnumValues adds orig.Enum values to type named n's Enum values in domain.
    private def self.add_enum_values(n : String, param : Pdl::Type, parent : Pdl::Type, d : Pdl::Domain)
      # find type
      typ = d.types.find { |type_elem| type_elem.raw_name == n }
      if typ.nil?
        typ = Pdl::Type.new(
          raw_type: param.raw_type,
          raw_name: n,
          is_circular_dep: param.is_circular_dep?,
          name: n.sub(/^#{Regex.escape(d.domain)}\\./, ""),
          type: Pdl::TypeEnum::String,
          description: param.description,
          optional: param.optional?,
          always_emit: param.always_emit?,
          enum: [] of String
        )
        d.types << typ
      end

      # combine typ.Enum and vals
      values_set = Set(String).new
      all = (typ.enum || [] of String) + (param.enum || [] of String)
      all.each do |value|
        values_set << value
      end

      typ.enum = values_set.to_a
    end

    # enumRefMap is the fully qualified parameter name to ref.
    private ENUM_REF_MAP = {
      "Animation.Animation.type"                              => "Type",
      "Console.ConsoleMessage.level"                          => "MessageLevel",
      "Console.ConsoleMessage.source"                         => "MessageSource",
      "CSS.CSSMedia.source"                                   => "MediaSource",
      "CSS.forcePseudoState.forcedPseudoClasses"              => "PseudoClass",
      "Debugger.setPauseOnExceptions.state"                   => "ExceptionsState",
      "Emulation.ScreenOrientation.type"                      => "OrientationType",
      "Emulation.setTouchEmulationEnabledomain.configuration" => "EnabledConfiguration",
      "Input.dispatchKeyEvent.type"                           => "KeyType",
      "Input.dispatchMouseEvent.button"                       => "ButtonType",
      "Input.dispatchMouseEvent.type"                         => "MouseType",
      "Input.dispatchTouchEvent.type"                         => "TouchType",
      "Input.emulateTouchFromMouseEvent.button"               => "ButtonType",
      "Input.emulateTouchFromMouseEvent.type"                 => "MouseType",
      "Input.TouchPoint.state"                                => "TouchState",
      "Log.LogEntry.level"                                    => "Level",
      "Log.LogEntry.source"                                   => "Source",
      "Log.ViolationSetting.name"                             => "Violation",
      "Network.Request.mixedContentType"                      => "MixedContentType",
      "Network.Request.referrerPolicy"                        => "ReferrerPolicy",
      "Page.startScreencast.format"                           => "ScreencastFormat",
      "Runtime.consoleAPICalledomain.type"                    => "APIType",
      "Runtime.ObjectPreview.subtype"                         => "Subtype",
      "Runtime.ObjectPreview.type"                            => "Type",
      "Runtime.PropertyPreview.subtype"                       => "Subtype",
      "Runtime.PropertyPreview.type"                          => "Type",
      "Runtime.RemoteObject.subtype"                          => "Subtype",
      "Runtime.RemoteObject.type"                             => "Type",
      "Tracing.start.transferMode"                            => "TransferMode",
      "Tracing.TraceConfig.recordMode"                        => "RecordMode",
    }

    # fixupEnumParameter takes an enum parameter, adds it to the domain and
    # returns a type suitable for use in place of the type.
    private def self.fixup_enum_parameter(typ : String, p : Pdl::Type, parent : Pdl::Type, d : Pdl::Domain) : Pdl::Type
      fqname = "#{d.domain}.#{typ}.#{p.name}".chomp('.')
      ref = snaker_force_camel_identifier(typ + "." + p.name)
      if n = ENUM_REF_MAP[fqname]?
        ref = n
      end
      raw_name = d.domain + "." + ref

      # add enum values to type name
      add_enum_values(raw_name, p, parent, d)

      Pdl::Type.new(
        raw_type: p.raw_type,
        raw_name: raw_name,
        name: p.name,
        ref: ref,
        description: p.description,
        optional: p.optional?,
        always_emit: p.always_emit?
      )
    end

    # Helper to convert snake_case to CamelCase (simplified)
    private def self.snaker_force_camel_identifier(s : String) : String
      # TODO: implement proper conversion
      s.split('.').map(&.camelcase).join
    end
  end
end
