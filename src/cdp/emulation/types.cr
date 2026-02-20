require "../emulation/emulation"
require "json"
require "time"
require "../dom/dom"
require "../page/page"
require "../network/network"

module Cdp::Emulation
  @[Experimental]
  struct SafeAreaInsets
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property top : Int64?
    @[JSON::Field(emit_null: false)]
    property top_max : Int64?
    @[JSON::Field(emit_null: false)]
    property left : Int64?
    @[JSON::Field(emit_null: false)]
    property left_max : Int64?
    @[JSON::Field(emit_null: false)]
    property bottom : Int64?
    @[JSON::Field(emit_null: false)]
    property bottom_max : Int64?
    @[JSON::Field(emit_null: false)]
    property right : Int64?
    @[JSON::Field(emit_null: false)]
    property right_max : Int64?
  end

  struct ScreenOrientation
    include JSON::Serializable

    property type : OrientationType
    property angle : Int64
  end

  struct DisplayFeature
    include JSON::Serializable

    property orientation : DisplayFeatureOrientation
    property offset : Int64
    property mask_length : Int64
  end

  struct DevicePosture
    include JSON::Serializable

    property type : DevicePostureType
  end

  struct MediaFeature
    include JSON::Serializable

    property name : String
    property value : String
  end

  @[Experimental]
  alias VirtualTimePolicy = String

  @[Experimental]
  struct UserAgentBrandVersion
    include JSON::Serializable

    property brand : String
    property version : String
  end

  @[Experimental]
  struct UserAgentMetadata
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property brands : Array(UserAgentBrandVersion)?
    @[JSON::Field(emit_null: false)]
    property full_version_list : Array(UserAgentBrandVersion)?
    property platform : String
    property platform_version : String
    property architecture : String
    property model : String
    property mobile : Bool
    @[JSON::Field(emit_null: false)]
    property bitness : String?
    @[JSON::Field(emit_null: false)]
    property wow64 : Bool?
    @[JSON::Field(emit_null: false)]
    property form_factors : Array(String)?
  end

  @[Experimental]
  alias SensorType = String

  @[Experimental]
  struct SensorMetadata
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property available : Bool?
    @[JSON::Field(emit_null: false)]
    property minimum_frequency : Float64?
    @[JSON::Field(emit_null: false)]
    property maximum_frequency : Float64?
  end

  @[Experimental]
  struct SensorReadingSingle
    include JSON::Serializable

    property value : Float64
  end

  @[Experimental]
  struct SensorReadingXYZ
    include JSON::Serializable

    property x : Float64
    property y : Float64
    property z : Float64
  end

  @[Experimental]
  struct SensorReadingQuaternion
    include JSON::Serializable

    property x : Float64
    property y : Float64
    property z : Float64
    property w : Float64
  end

  @[Experimental]
  struct SensorReading
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property single : SensorReadingSingle?
    @[JSON::Field(emit_null: false)]
    property xyz : SensorReadingXYZ?
    @[JSON::Field(emit_null: false)]
    property quaternion : SensorReadingQuaternion?
  end

  @[Experimental]
  alias PressureSource = String

  @[Experimental]
  alias PressureState = String

  @[Experimental]
  struct PressureMetadata
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property available : Bool?
  end

  @[Experimental]
  struct WorkAreaInsets
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property top : Int64?
    @[JSON::Field(emit_null: false)]
    property left : Int64?
    @[JSON::Field(emit_null: false)]
    property bottom : Int64?
    @[JSON::Field(emit_null: false)]
    property right : Int64?
  end

  @[Experimental]
  alias ScreenId = String

  @[Experimental]
  struct ScreenInfo
    include JSON::Serializable

    property left : Int64
    property top : Int64
    property width : Int64
    property height : Int64
    property avail_left : Int64
    property avail_top : Int64
    property avail_width : Int64
    property avail_height : Int64
    property device_pixel_ratio : Float64
    property orientation : ScreenOrientation
    property color_depth : Int64
    property is_extended : Bool
    property is_internal : Bool
    property is_primary : Bool
    property label : String
    property id : ScreenId
  end

  @[Experimental]
  alias DisabledImageType = String

  alias OrientationType = String

  alias DisplayFeatureOrientation = String

  alias DevicePostureType = String

  alias SetEmitTouchEventsForMouseConfiguration = String

  alias SetEmulatedVisionDeficiencyType = String
end
