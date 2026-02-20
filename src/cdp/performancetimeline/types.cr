require "../performancetimeline/performancetimeline"
require "json"
require "time"

module Cdp::PerformanceTimeline
  struct LargestContentfulPaint
    include JSON::Serializable

    property render_time : Cdp::Network::TimeSinceEpoch
    property load_time : Cdp::Network::TimeSinceEpoch
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

    property previous_rect : Cdp::DOM::Rect
    property current_rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?
  end

  struct LayoutShift
    include JSON::Serializable

    property value : Float64
    property had_recent_input : Bool
    property last_input_time : Cdp::Network::TimeSinceEpoch
    property sources : Array(LayoutShiftAttribution)
  end

  struct TimelineEvent
    include JSON::Serializable

    property frame_id : Cdp::Page::FrameId
    property type : String
    property name : String
    property time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property duration : Float64?
    @[JSON::Field(emit_null: false)]
    property lcp_details : LargestContentfulPaint?
    @[JSON::Field(emit_null: false)]
    property layout_shift_details : LayoutShift?
  end
end
