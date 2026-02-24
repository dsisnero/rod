require "../cdp"
require "json"
require "time"

require "../network/network"
require "../dom/dom"
require "../page/page"

module Cdp::PerformanceTimeline
  struct LargestContentfulPaint
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property render_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property load_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property size : Float64
    @[JSON::Field(emit_null: false)]
    property element_id : String?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?
  end

  struct LayoutShiftAttribution
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property previous_rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property current_rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?
  end

  struct LayoutShift
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property value : Float64
    @[JSON::Field(emit_null: false)]
    property? had_recent_input : Bool
    @[JSON::Field(emit_null: false)]
    property last_input_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property sources : Array(LayoutShiftAttribution)
  end

  struct TimelineEvent
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property type : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property duration : Float64?
    @[JSON::Field(emit_null: false)]
    property lcp_details : LargestContentfulPaint?
    @[JSON::Field(emit_null: false)]
    property layout_shift_details : LayoutShift?
  end
end
