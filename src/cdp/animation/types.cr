require "../animation/animation"
require "json"
require "time"
require "../runtime/runtime"

module Cdp::Animation
  struct Animation
    include JSON::Serializable

    property id : String
    property name : String
    property paused_state : Bool
    property play_state : String
    property playback_rate : Float64
    property start_time : Float64
    property current_time : Float64
    property type : Type
    @[JSON::Field(emit_null: false)]
    property source : AnimationEffect?
    @[JSON::Field(emit_null: false)]
    property css_id : String?
    @[JSON::Field(emit_null: false)]
    property view_or_scroll_timeline : ViewOrScrollTimeline?
  end

  struct ViewOrScrollTimeline
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property source_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property start_offset : Float64?
    @[JSON::Field(emit_null: false)]
    property end_offset : Float64?
    @[JSON::Field(emit_null: false)]
    property subject_node_id : Cdp::DOM::BackendNodeId?
    property axis : Cdp::DOM::ScrollOrientation
  end

  struct AnimationEffect
    include JSON::Serializable

    property delay : Float64
    property end_delay : Float64
    property iteration_start : Float64
    @[JSON::Field(emit_null: false)]
    property iterations : Float64?
    property duration : Float64
    property direction : String
    property fill : String
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property keyframes_rule : KeyframesRule?
    property easing : String
  end

  struct KeyframesRule
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property name : String?
    property keyframes : Array(KeyframeStyle)
  end

  struct KeyframeStyle
    include JSON::Serializable

    property offset : String
    property easing : String
  end

  alias Type = String
end
