module Pdlgen
  module Gen
    module CrystalExtras
      # Returns Crystal code for FrameState enum (bitmask) and related constants.
      def self.extra_frame_template : String
        String.build do |str|
          str << "# FrameState is the state of a Frame.\n"
          str << "@[Flags]\n"
          str << "enum FrameState : UInt16\n"
          str << "  # Frame state flags\n"
          str << "  FrameDOMContentEventFired = 1 << 15\n"
          str << "  FrameLoadEventFired       = 1 << 14\n"
          str << "  FrameAttached             = 1 << 13\n"
          str << "  FrameNavigated            = 1 << 12\n"
          str << "  FrameLoading              = 1 << 11\n"
          str << "  FrameScheduledNavigation  = 1 << 10\n"
          str << "end\n\n"
          str << "# EmptyFrameID is the \"non-existent\" frame id.\n"
          str << "EMPTY_FRAME_ID = FrameId.new(\"\")\n"
        end
      end

      # Returns Crystal code for NodeState enum (bitmask) and related constants.
      def self.extra_node_template : String
        String.build do |str|
          str << "# NodeState is the state of a DOM node.\n"
          str << "@[Flags]\n"
          str << "enum NodeState : UInt8\n"
          str << "  # Node state flags\n"
          str << "  NodeReady          = 1 << 7\n"
          str << "  NodeChildReady     = 1 << 6\n"
          str << "  NodeDescendantReady = 1 << 5\n"
          str << "  NodeAttached       = 1 << 4\n"
          str << "  NodeHasShadowRoot  = 1 << 3\n"
          str << "  NodeMutated        = 1 << 2\n"
          str << "end\n"
        end
      end

      # Returns Crystal code for Node type extensions (Attribute, AttributeValue methods).
      # Note: These methods need to be placed inside the Node struct definition,
      # not as extra content after the type.
      def self.node_methods : String
        <<-CRYSTAL
        # AttributeValue returns the named attribute for the node.
        def attribute_value(name : String) : String
          value = attribute(name)
          value || ""
        end

        # Attribute returns the named attribute for the node and if it exists.
        def attribute(name : String) : String?
          @attributes.each_slice(2) do |pair|
            if pair[0] == name
              return pair[1]
            end
          end
          nil
        end
        CRYSTAL
      end

      # Returns Crystal code for Timestamp type marshal/unmarshal methods.
      # In Crystal, Time already implements JSON::Serializable properly,
      # but we need to handle monotonic timestamps if needed.
      def self.extra_timestamp_template(t : Pdl::Type, d : Pdl::Domain) : String
        # For now, return empty string as Time serialization is handled by JSON::Serializable
        ""
      end
    end
  end
end
