require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::PerformanceTimeline
  struct LargestContentfulPaint
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property render_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property load_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property size : Float64
    @[JSON::Field(emit_null: false)]
    property element_id : String?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
  end

  struct LayoutShiftAttribution
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property previous_rect : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property current_rect : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
  end

  struct LayoutShift
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property value : Float64
    @[JSON::Field(emit_null: false)]
    property? had_recent_input : Bool
    @[JSON::Field(emit_null: false)]
    property last_input_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property sources : Array(Cdp::NodeType)
  end

  struct TimelineEvent
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property duration : Float64?
    @[JSON::Field(emit_null: false)]
    property lcp_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property layout_shift_details : Cdp::NodeType?
  end
end
