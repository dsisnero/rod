require "../cdp"
require "json"
require "time"

require "../dom/dom"

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
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property angle : Int64
  end

  struct DisplayFeature
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property orientation : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property offset : Int64
    @[JSON::Field(emit_null: false)]
    property mask_length : Int64
  end

  struct DevicePosture
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
  end

  struct MediaFeature
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  @[Experimental]
  alias VirtualTimePolicy = String
  VirtualTimePolicyAdvance                      = "advance"
  VirtualTimePolicyPause                        = "pause"
  VirtualTimePolicyPauseIfNetworkFetchesPending = "pauseIfNetworkFetchesPending"

  @[Experimental]
  struct UserAgentBrandVersion
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property brand : String
    @[JSON::Field(emit_null: false)]
    property version : String
  end

  @[Experimental]
  struct UserAgentMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property brands : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property full_version_list : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property platform : String
    @[JSON::Field(emit_null: false)]
    property platform_version : String
    @[JSON::Field(emit_null: false)]
    property architecture : String
    @[JSON::Field(emit_null: false)]
    property model : String
    @[JSON::Field(emit_null: false)]
    property? mobile : Bool
    @[JSON::Field(emit_null: false)]
    property bitness : String?
    @[JSON::Field(emit_null: false)]
    property? wow64 : Bool?
    @[JSON::Field(emit_null: false)]
    property form_factors : Array(String)?
  end

  @[Experimental]
  alias SensorType = String
  SensorTypeAbsoluteOrientation = "absolute-orientation"
  SensorTypeAccelerometer       = "accelerometer"
  SensorTypeAmbientLight        = "ambient-light"
  SensorTypeGravity             = "gravity"
  SensorTypeGyroscope           = "gyroscope"
  SensorTypeLinearAcceleration  = "linear-acceleration"
  SensorTypeMagnetometer        = "magnetometer"
  SensorTypeRelativeOrientation = "relative-orientation"

  @[Experimental]
  struct SensorMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? available : Bool?
    @[JSON::Field(emit_null: false)]
    property minimum_frequency : Float64?
    @[JSON::Field(emit_null: false)]
    property maximum_frequency : Float64?
  end

  @[Experimental]
  struct SensorReadingSingle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property value : Float64
  end

  @[Experimental]
  struct SensorReadingXYZ
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property x : Float64
    @[JSON::Field(emit_null: false)]
    property y : Float64
    @[JSON::Field(emit_null: false)]
    property z : Float64
  end

  @[Experimental]
  struct SensorReadingQuaternion
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property x : Float64
    @[JSON::Field(emit_null: false)]
    property y : Float64
    @[JSON::Field(emit_null: false)]
    property z : Float64
    @[JSON::Field(emit_null: false)]
    property w : Float64
  end

  @[Experimental]
  struct SensorReading
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property single : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property xyz : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property quaternion : Cdp::NodeType?
  end

  @[Experimental]
  alias PressureSource = String
  PressureSourceCpu = "cpu"

  @[Experimental]
  alias PressureState = String
  PressureStateNominal  = "nominal"
  PressureStateFair     = "fair"
  PressureStateSerious  = "serious"
  PressureStateCritical = "critical"

  @[Experimental]
  struct PressureMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? available : Bool?
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
    @[JSON::Field(emit_null: false)]
    property left : Int64
    @[JSON::Field(emit_null: false)]
    property top : Int64
    @[JSON::Field(emit_null: false)]
    property width : Int64
    @[JSON::Field(emit_null: false)]
    property height : Int64
    @[JSON::Field(emit_null: false)]
    property avail_left : Int64
    @[JSON::Field(emit_null: false)]
    property avail_top : Int64
    @[JSON::Field(emit_null: false)]
    property avail_width : Int64
    @[JSON::Field(emit_null: false)]
    property avail_height : Int64
    @[JSON::Field(emit_null: false)]
    property device_pixel_ratio : Float64
    @[JSON::Field(emit_null: false)]
    property orientation : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property color_depth : Int64
    @[JSON::Field(emit_null: false)]
    property? is_extended : Bool
    @[JSON::Field(emit_null: false)]
    property? is_internal : Bool
    @[JSON::Field(emit_null: false)]
    property? is_primary : Bool
    @[JSON::Field(emit_null: false)]
    property label : String
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType
  end

  @[Experimental]
  alias DisabledImageType = String
  DisabledImageTypeAvif = "avif"
  DisabledImageTypeWebp = "webp"

  alias OrientationType = String
  OrientationTypePortraitPrimary    = "portraitPrimary"
  OrientationTypePortraitSecondary  = "portraitSecondary"
  OrientationTypeLandscapePrimary   = "landscapePrimary"
  OrientationTypeLandscapeSecondary = "landscapeSecondary"

  alias DisplayFeatureOrientation = String
  DisplayFeatureOrientationVertical   = "vertical"
  DisplayFeatureOrientationHorizontal = "horizontal"

  alias DevicePostureType = String
  DevicePostureTypeContinuous = "continuous"
  DevicePostureTypeFolded     = "folded"

  alias SetEmitTouchEventsForMouseConfiguration = String
  SetEmitTouchEventsForMouseConfigurationMobile  = "mobile"
  SetEmitTouchEventsForMouseConfigurationDesktop = "desktop"

  alias SetEmulatedVisionDeficiencyType = String
  SetEmulatedVisionDeficiencyTypeNone            = "none"
  SetEmulatedVisionDeficiencyTypeBlurredVision   = "blurredVision"
  SetEmulatedVisionDeficiencyTypeReducedContrast = "reducedContrast"
  SetEmulatedVisionDeficiencyTypeAchromatopsia   = "achromatopsia"
  SetEmulatedVisionDeficiencyTypeDeuteranopia    = "deuteranopia"
  SetEmulatedVisionDeficiencyTypeProtanopia      = "protanopia"
  SetEmulatedVisionDeficiencyTypeTritanopia      = "tritanopia"
end
