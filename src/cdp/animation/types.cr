require "../cdp"
require "json"
require "base64"
require "time"

require "../dom/dom"
require "../runtime/runtime"

module Cdp::Animation
  struct Animation
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "pausedState", emit_null: false)]
    property? paused_state : Bool
    @[JSON::Field(key: "playState", emit_null: false)]
    property play_state : String
    @[JSON::Field(key: "playbackRate", emit_null: false)]
    property playback_rate : Float64
    @[JSON::Field(key: "startTime", emit_null: false)]
    property start_time : Float64
    @[JSON::Field(key: "currentTime", emit_null: false)]
    property current_time : Float64
    @[JSON::Field(key: "type", emit_null: false)]
    property type : Type
    @[JSON::Field(key: "source", emit_null: false)]
    property source : AnimationEffect?
    @[JSON::Field(key: "cssId", emit_null: false)]
    property css_id : String?
    @[JSON::Field(key: "viewOrScrollTimeline", emit_null: false)]
    property view_or_scroll_timeline : ViewOrScrollTimeline?

    def initialize(@id : String, @name : String, @paused_state : Bool, @play_state : String, @playback_rate : Float64, @start_time : Float64, @current_time : Float64, @type : Type, @source : AnimationEffect? = nil, @css_id : String? = nil, @view_or_scroll_timeline : ViewOrScrollTimeline? = nil)
    end
  end

  struct ViewOrScrollTimeline
    include JSON::Serializable
    @[JSON::Field(key: "sourceNodeId", emit_null: false)]
    property source_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "startOffset", emit_null: false)]
    property start_offset : Float64?
    @[JSON::Field(key: "endOffset", emit_null: false)]
    property end_offset : Float64?
    @[JSON::Field(key: "subjectNodeId", emit_null: false)]
    property subject_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "axis", emit_null: false)]
    property axis : Cdp::DOM::ScrollOrientation

    def initialize(@axis : Cdp::DOM::ScrollOrientation, @source_node_id : Cdp::DOM::BackendNodeId? = nil, @start_offset : Float64? = nil, @end_offset : Float64? = nil, @subject_node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end

  struct AnimationEffect
    include JSON::Serializable
    @[JSON::Field(key: "delay", emit_null: false)]
    property delay : Float64
    @[JSON::Field(key: "endDelay", emit_null: false)]
    property end_delay : Float64
    @[JSON::Field(key: "iterationStart", emit_null: false)]
    property iteration_start : Float64
    @[JSON::Field(key: "iterations", emit_null: false)]
    property iterations : Float64?
    @[JSON::Field(key: "duration", emit_null: false)]
    property duration : Float64
    @[JSON::Field(key: "direction", emit_null: false)]
    property direction : String
    @[JSON::Field(key: "fill", emit_null: false)]
    property fill : String
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "keyframesRule", emit_null: false)]
    property keyframes_rule : KeyframesRule?
    @[JSON::Field(key: "easing", emit_null: false)]
    property easing : String

    def initialize(@delay : Float64, @end_delay : Float64, @iteration_start : Float64, @duration : Float64, @direction : String, @fill : String, @easing : String, @iterations : Float64? = nil, @backend_node_id : Cdp::DOM::BackendNodeId? = nil, @keyframes_rule : KeyframesRule? = nil)
    end
  end

  struct KeyframesRule
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String?
    @[JSON::Field(key: "keyframes", emit_null: false)]
    property keyframes : Array(KeyframeStyle)

    def initialize(@keyframes : Array(KeyframeStyle), @name : String? = nil)
    end
  end

  struct KeyframeStyle
    include JSON::Serializable
    @[JSON::Field(key: "offset", emit_null: false)]
    property offset : String
    @[JSON::Field(key: "easing", emit_null: false)]
    property easing : String

    def initialize(@offset : String, @easing : String)
    end
  end

  alias Type = String
  TypeCSSTransition = "CSSTransition"
  TypeCSSAnimation  = "CSSAnimation"
  TypeWebAnimation  = "WebAnimation"
end
