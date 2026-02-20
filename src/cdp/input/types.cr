require "../input/input"
require "json"
require "time"

module Cdp::Input
  struct TouchPoint
    include JSON::Serializable

    property x : Float64
    property y : Float64
    @[JSON::Field(emit_null: false)]
    property radius_x : Float64?
    @[JSON::Field(emit_null: false)]
    property radius_y : Float64?
    @[JSON::Field(emit_null: false)]
    property rotation_angle : Float64?
    @[JSON::Field(emit_null: false)]
    property force : Float64?
    @[JSON::Field(emit_null: false)]
    property tangential_pressure : Float64?
    @[JSON::Field(emit_null: false)]
    property tilt_x : Float64?
    @[JSON::Field(emit_null: false)]
    property tilt_y : Float64?
    @[JSON::Field(emit_null: false)]
    property twist : Int64?
    @[JSON::Field(emit_null: false)]
    property id : Float64?
  end

  @[Experimental]
  alias GestureSourceType = String

  alias MouseButton = String

  alias TimeSinceEpoch = Time

  @[Experimental]
  struct DragDataItem
    include JSON::Serializable

    property mime_type : String
    property data : String
    @[JSON::Field(emit_null: false)]
    property title : String?
    @[JSON::Field(emit_null: false)]
    property base_url : String?
  end

  @[Experimental]
  struct DragData
    include JSON::Serializable

    property items : Array(DragDataItem)
    @[JSON::Field(emit_null: false)]
    property files : Array(String)?
    property drag_operations_mask : Int64
  end

  alias Modifier = Int64

  alias DispatchDragEventType = String

  alias KeyType = String

  alias MouseType = String

  alias DispatchMouseEventPointerType = String

  alias TouchType = String

  alias Modifier = Int64
end
