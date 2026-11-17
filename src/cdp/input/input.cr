require "../cdp"
require "json"
require "time"

require "./types"
require "./events"

#
module Cdp::Input
  # Commands
  @[Experimental]
  struct DispatchDragEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : DispatchDragEventType
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "data", emit_null: false)]
    property data : DragData
    @[JSON::Field(key: "modifiers", emit_null: false)]
    property modifiers : Modifier?

    def initialize(@type : DispatchDragEventType, @x : Float64, @y : Float64, @data : DragData, @modifiers : Modifier? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.dispatchDragEvent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DispatchKeyEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : KeyType
    @[JSON::Field(key: "modifiers", emit_null: false)]
    property modifiers : Modifier?
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : TimeSinceEpoch?
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String?
    @[JSON::Field(key: "unmodifiedText", emit_null: false)]
    property unmodified_text : String?
    @[JSON::Field(key: "keyIdentifier", emit_null: false)]
    property key_identifier : String?
    @[JSON::Field(key: "code", emit_null: false)]
    property code : String?
    @[JSON::Field(key: "key", emit_null: false)]
    property key : String?
    @[JSON::Field(key: "windowsVirtualKeyCode", emit_null: false)]
    property windows_virtual_key_code : Int64?
    @[JSON::Field(key: "nativeVirtualKeyCode", emit_null: false)]
    property native_virtual_key_code : Int64?
    @[JSON::Field(key: "autoRepeat", emit_null: false)]
    property? auto_repeat : Bool?
    @[JSON::Field(key: "isKeypad", emit_null: false)]
    property? is_keypad : Bool?
    @[JSON::Field(key: "isSystemKey", emit_null: false)]
    property? is_system_key : Bool?
    @[JSON::Field(key: "location", emit_null: false)]
    property location : Int64?
    @[JSON::Field(key: "commands", emit_null: false)]
    property commands : Array(String)?

    def initialize(@type : KeyType, @modifiers : Modifier? = nil, @timestamp : TimeSinceEpoch? = nil, @text : String? = nil, @unmodified_text : String? = nil, @key_identifier : String? = nil, @code : String? = nil, @key : String? = nil, @windows_virtual_key_code : Int64? = nil, @native_virtual_key_code : Int64? = nil, @auto_repeat : Bool? = nil, @is_keypad : Bool? = nil, @is_system_key : Bool? = nil, @location : Int64? = nil, @commands : Array(String)? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.dispatchKeyEvent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct InsertText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String

    def initialize(@text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.insertText"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ImeSetComposition
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "selectionStart", emit_null: false)]
    property selection_start : Int64
    @[JSON::Field(key: "selectionEnd", emit_null: false)]
    property selection_end : Int64
    @[JSON::Field(key: "replacementStart", emit_null: false)]
    property replacement_start : Int64?
    @[JSON::Field(key: "replacementEnd", emit_null: false)]
    property replacement_end : Int64?

    def initialize(@text : String, @selection_start : Int64, @selection_end : Int64, @replacement_start : Int64? = nil, @replacement_end : Int64? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.imeSetComposition"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DispatchMouseEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : MouseType
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "modifiers", emit_null: false)]
    property modifiers : Modifier?
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : TimeSinceEpoch?
    @[JSON::Field(key: "button", emit_null: false)]
    property button : MouseButton?
    @[JSON::Field(key: "buttons", emit_null: false)]
    property buttons : Int64?
    @[JSON::Field(key: "clickCount", emit_null: false)]
    property click_count : Int64?
    @[JSON::Field(key: "force", emit_null: false)]
    property force : Float64?
    @[JSON::Field(key: "tangentialPressure", emit_null: false)]
    property tangential_pressure : Float64?
    @[JSON::Field(key: "tiltX", emit_null: false)]
    property tilt_x : Float64?
    @[JSON::Field(key: "tiltY", emit_null: false)]
    property tilt_y : Float64?
    @[JSON::Field(key: "twist", emit_null: false)]
    property twist : Int64?
    @[JSON::Field(key: "deltaX", emit_null: false)]
    property delta_x : Float64?
    @[JSON::Field(key: "deltaY", emit_null: false)]
    property delta_y : Float64?
    @[JSON::Field(key: "pointerType", emit_null: false)]
    property pointer_type : DispatchMouseEventPointerType?

    def initialize(@type : MouseType, @x : Float64, @y : Float64, @modifiers : Modifier? = nil, @timestamp : TimeSinceEpoch? = nil, @button : MouseButton? = nil, @buttons : Int64? = nil, @click_count : Int64? = nil, @force : Float64? = nil, @tangential_pressure : Float64? = nil, @tilt_x : Float64? = nil, @tilt_y : Float64? = nil, @twist : Int64? = nil, @delta_x : Float64? = nil, @delta_y : Float64? = nil, @pointer_type : DispatchMouseEventPointerType? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.dispatchMouseEvent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DispatchTouchEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : TouchType
    @[JSON::Field(key: "touchPoints", emit_null: false)]
    property touch_points : Array(TouchPoint)
    @[JSON::Field(key: "modifiers", emit_null: false)]
    property modifiers : Modifier?
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : TimeSinceEpoch?

    def initialize(@type : TouchType, @touch_points : Array(TouchPoint), @modifiers : Modifier? = nil, @timestamp : TimeSinceEpoch? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.dispatchTouchEvent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CancelDragging
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.cancelDragging"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct EmulateTouchFromMouseEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : MouseType
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Int64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Int64
    @[JSON::Field(key: "button", emit_null: false)]
    property button : MouseButton
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : TimeSinceEpoch?
    @[JSON::Field(key: "deltaX", emit_null: false)]
    property delta_x : Float64?
    @[JSON::Field(key: "deltaY", emit_null: false)]
    property delta_y : Float64?
    @[JSON::Field(key: "modifiers", emit_null: false)]
    property modifiers : Modifier?
    @[JSON::Field(key: "clickCount", emit_null: false)]
    property click_count : Int64?

    def initialize(@type : MouseType, @x : Int64, @y : Int64, @button : MouseButton, @timestamp : TimeSinceEpoch? = nil, @delta_x : Float64? = nil, @delta_y : Float64? = nil, @modifiers : Modifier? = nil, @click_count : Int64? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.emulateTouchFromMouseEvent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetIgnoreInputEvents
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "ignore", emit_null: false)]
    property? ignore : Bool

    def initialize(@ignore : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.setIgnoreInputEvents"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetInterceptDrags
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.setInterceptDrags"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SynthesizePinchGesture
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "scaleFactor", emit_null: false)]
    property scale_factor : Float64
    @[JSON::Field(key: "relativeSpeed", emit_null: false)]
    property relative_speed : Int64?
    @[JSON::Field(key: "gestureSourceType", emit_null: false)]
    property gesture_source_type : GestureSourceType?

    def initialize(@x : Float64, @y : Float64, @scale_factor : Float64, @relative_speed : Int64? = nil, @gesture_source_type : GestureSourceType? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.synthesizePinchGesture"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SynthesizeScrollGesture
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "xDistance", emit_null: false)]
    property x_distance : Float64?
    @[JSON::Field(key: "yDistance", emit_null: false)]
    property y_distance : Float64?
    @[JSON::Field(key: "xOverscroll", emit_null: false)]
    property x_overscroll : Float64?
    @[JSON::Field(key: "yOverscroll", emit_null: false)]
    property y_overscroll : Float64?
    @[JSON::Field(key: "preventFling", emit_null: false)]
    property? prevent_fling : Bool?
    @[JSON::Field(key: "speed", emit_null: false)]
    property speed : Int64?
    @[JSON::Field(key: "gestureSourceType", emit_null: false)]
    property gesture_source_type : GestureSourceType?
    @[JSON::Field(key: "repeatCount", emit_null: false)]
    property repeat_count : Int64?
    @[JSON::Field(key: "repeatDelayMs", emit_null: false)]
    property repeat_delay_ms : Int64?
    @[JSON::Field(key: "interactionMarkerName", emit_null: false)]
    property interaction_marker_name : String?

    def initialize(@x : Float64, @y : Float64, @x_distance : Float64? = nil, @y_distance : Float64? = nil, @x_overscroll : Float64? = nil, @y_overscroll : Float64? = nil, @prevent_fling : Bool? = nil, @speed : Int64? = nil, @gesture_source_type : GestureSourceType? = nil, @repeat_count : Int64? = nil, @repeat_delay_ms : Int64? = nil, @interaction_marker_name : String? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.synthesizeScrollGesture"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SynthesizeTapGesture
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "duration", emit_null: false)]
    property duration : Int64?
    @[JSON::Field(key: "tapCount", emit_null: false)]
    property tap_count : Int64?
    @[JSON::Field(key: "gestureSourceType", emit_null: false)]
    property gesture_source_type : GestureSourceType?

    def initialize(@x : Float64, @y : Float64, @duration : Int64? = nil, @tap_count : Int64? = nil, @gesture_source_type : GestureSourceType? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Input.synthesizeTapGesture"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
