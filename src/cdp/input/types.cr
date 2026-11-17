require "../cdp"
require "json"
require "base64"
require "time"

module Cdp::Input
  struct TouchPoint
    include JSON::Serializable
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "radiusX", emit_null: false)]
    property radius_x : Float64?
    @[JSON::Field(key: "radiusY", emit_null: false)]
    property radius_y : Float64?
    @[JSON::Field(key: "rotationAngle", emit_null: false)]
    property rotation_angle : Float64?
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
    @[JSON::Field(key: "id", emit_null: false)]
    property id : Float64?

    def initialize(@x : Float64, @y : Float64, @radius_x : Float64? = nil, @radius_y : Float64? = nil, @rotation_angle : Float64? = nil, @force : Float64? = nil, @tangential_pressure : Float64? = nil, @tilt_x : Float64? = nil, @tilt_y : Float64? = nil, @twist : Int64? = nil, @id : Float64? = nil)
    end

    # MoveTo updates X and Y coordinates.
    def move_to(x : Float64, y : Float64) : Nil
      @x = x
      @y = y
    end
  end

  @[Experimental]
  alias GestureSourceType = String
  GestureDefault = "default"
  GestureTouch   = "touch"
  GestureMouse   = "mouse"

  alias MouseButton = String
  None    = "none"
  Left    = "left"
  Middle  = "middle"
  Right   = "right"
  Back    = "back"
  Forward = "forward"

  alias TimeSinceEpoch = Time

  @[Experimental]
  struct DragDataItem
    include JSON::Serializable
    @[JSON::Field(key: "mimeType", emit_null: false)]
    property mime_type : String
    @[JSON::Field(key: "data", emit_null: false)]
    property data : String
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String?
    @[JSON::Field(key: "baseURL", emit_null: false)]
    property base_url : String?

    def initialize(@mime_type : String, @data : String, @title : String? = nil, @base_url : String? = nil)
    end
  end

  @[Experimental]
  struct DragData
    include JSON::Serializable
    @[JSON::Field(key: "items", emit_null: false)]
    property items : Array(DragDataItem)
    @[JSON::Field(key: "files", emit_null: false)]
    property files : Array(String)?
    @[JSON::Field(key: "dragOperationsMask", emit_null: false)]
    property drag_operations_mask : Int64

    def initialize(@items : Array(DragDataItem), @drag_operations_mask : Int64, @files : Array(String)? = nil)
    end
  end

  @[Flags]
  enum Modifier : Int64
    Alt
    Ctrl
    Meta
    Shift

    # CDP enums travel as their integer value, not their Crystal name.
    def to_json(json : JSON::Builder)
      json.number(value)
    end

    # `@[Flags]` enums otherwise decode from an array of member names, but CDP
    # sends the integer bitmask.
    def self.new(pull : JSON::PullParser)
      new(pull.read_int)
    end
  end
  # ModifierCommand is an alias for ModifierMeta.
  ModifierCommand = Modifier::Meta

  alias DispatchDragEventType = String
  DragEnter  = "dragEnter"
  DragOver   = "dragOver"
  Drop       = "drop"
  DragCancel = "dragCancel"

  alias KeyType = String
  KeyDown    = "keyDown"
  KeyUp      = "keyUp"
  KeyRawDown = "rawKeyDown"
  KeyChar    = "char"

  alias MouseType = String
  MousePressed  = "mousePressed"
  MouseReleased = "mouseReleased"
  MouseMoved    = "mouseMoved"
  MouseWheel    = "mouseWheel"

  alias DispatchMouseEventPointerType = String
  Mouse = "mouse"
  Pen   = "pen"

  alias TouchType = String
  TouchStart  = "touchStart"
  TouchEnd    = "touchEnd"
  TouchMove   = "touchMove"
  TouchCancel = "touchCancel"
end
