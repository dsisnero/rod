require "../cdp"
require "json"
require "base64"
require "time"

require "../network/network"
require "../dom/dom"
require "../page/page"

module Cdp::PerformanceTimeline
  struct LargestContentfulPaint
    include JSON::Serializable
    @[JSON::Field(key: "renderTime", emit_null: false)]
    property render_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "loadTime", emit_null: false)]
    property load_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Float64
    @[JSON::Field(key: "elementId", emit_null: false)]
    property element_id : String?
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String?
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?

    def initialize(@render_time : Cdp::Network::TimeSinceEpoch, @load_time : Cdp::Network::TimeSinceEpoch, @size : Float64, @element_id : String? = nil, @url : String? = nil, @node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end

  struct LayoutShiftAttribution
    include JSON::Serializable
    @[JSON::Field(key: "previousRect", emit_null: false)]
    property previous_rect : Cdp::DOM::Rect
    @[JSON::Field(key: "currentRect", emit_null: false)]
    property current_rect : Cdp::DOM::Rect
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?

    def initialize(@previous_rect : Cdp::DOM::Rect, @current_rect : Cdp::DOM::Rect, @node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end

  struct LayoutShift
    include JSON::Serializable
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Float64
    @[JSON::Field(key: "hadRecentInput", emit_null: false)]
    property? had_recent_input : Bool
    @[JSON::Field(key: "lastInputTime", emit_null: false)]
    property last_input_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "sources", emit_null: false)]
    property sources : Array(LayoutShiftAttribution)

    def initialize(@value : Float64, @had_recent_input : Bool, @last_input_time : Cdp::Network::TimeSinceEpoch, @sources : Array(LayoutShiftAttribution))
    end
  end

  struct TimelineEvent
    include JSON::Serializable
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "time", emit_null: false)]
    property time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "duration", emit_null: false)]
    property duration : Float64?
    @[JSON::Field(key: "lcpDetails", emit_null: false)]
    property lcp_details : LargestContentfulPaint?
    @[JSON::Field(key: "layoutShiftDetails", emit_null: false)]
    property layout_shift_details : LayoutShift?

    def initialize(@frame_id : Cdp::Page::FrameId, @type : String, @name : String, @time : Cdp::Network::TimeSinceEpoch, @duration : Float64? = nil, @lcp_details : LargestContentfulPaint? = nil, @layout_shift_details : LayoutShift? = nil)
    end
  end
end
