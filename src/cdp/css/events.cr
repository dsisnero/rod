require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"

module Cdp::CSS
  struct FontsUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property font : FontFace?

    def initialize(@font : FontFace?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "CSS.fontsUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "CSS.fontsUpdated"
    end
  end

  struct MediaQueryResultChangedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "CSS.mediaQueryResultChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "CSS.mediaQueryResultChanged"
    end
  end

  struct StyleSheetAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property header : CSSStyleSheetHeader

    def initialize(@header : CSSStyleSheetHeader)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "CSS.styleSheetAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "CSS.styleSheetAdded"
    end
  end

  struct StyleSheetChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "CSS.styleSheetChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "CSS.styleSheetChanged"
    end
  end

  struct StyleSheetRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "CSS.styleSheetRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "CSS.styleSheetRemoved"
    end
  end

  @[Experimental]
  struct ComputedStyleUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "CSS.computedStyleUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "CSS.computedStyleUpdated"
    end
  end
end
