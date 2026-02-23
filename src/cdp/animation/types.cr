require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../runtime/runtime"

module Cdp::Animation
  struct Animation
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property? paused_state : Bool
    @[JSON::Field(emit_null: false)]
    property play_state : String
    @[JSON::Field(emit_null: false)]
    property playback_rate : Float64
    @[JSON::Field(emit_null: false)]
    property start_time : Float64
    @[JSON::Field(emit_null: false)]
    property current_time : Float64
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property axis : Cdp::DOM::ScrollOrientation
  end

  struct AnimationEffect
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property delay : Float64
    @[JSON::Field(emit_null: false)]
    property end_delay : Float64
    @[JSON::Field(emit_null: false)]
    property iteration_start : Float64
    @[JSON::Field(emit_null: false)]
    property iterations : Float64?
    @[JSON::Field(emit_null: false)]
    property duration : Float64
    @[JSON::Field(emit_null: false)]
    property direction : String
    @[JSON::Field(emit_null: false)]
    property fill : String
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property keyframes_rule : KeyframesRule?
    @[JSON::Field(emit_null: false)]
    property easing : String
  end

  struct KeyframesRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property keyframes : Array(KeyframeStyle)
  end

  struct KeyframeStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property offset : String
    @[JSON::Field(emit_null: false)]
    property easing : String
  end

  alias Type = String
  TypeCSSTransition = "CSSTransition"
  TypeCSSAnimation  = "CSSAnimation"
  TypeWebAnimation  = "WebAnimation"
end
