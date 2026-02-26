require "../cdp"
require "json"
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
  end

  @[Experimental]
  alias GestureSourceType = String
  Default = "default"
  Touch   = "touch"
  Mouse   = "mouse"

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
    @[JSON::Field(key: "baseUrl", emit_null: false)]
    property base_url : String?
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
  end

  @[Flags]
  enum Modifier : Int64
    None
    Alt
    Ctrl
    Meta
    Shift
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
  RawKeyDown = "rawKeyDown"
  Char       = "char"

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
