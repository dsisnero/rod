require "../cdp"
require "json"
require "base64"
require "time"

require "../dom/dom"
require "../page/page"
require "../network/network"

module Cdp::Emulation
  @[Experimental]
  struct SafeAreaInsets
    include JSON::Serializable
    @[JSON::Field(key: "top", emit_null: false)]
    property top : Int64?
    @[JSON::Field(key: "topMax", emit_null: false)]
    property top_max : Int64?
    @[JSON::Field(key: "left", emit_null: false)]
    property left : Int64?
    @[JSON::Field(key: "leftMax", emit_null: false)]
    property left_max : Int64?
    @[JSON::Field(key: "bottom", emit_null: false)]
    property bottom : Int64?
    @[JSON::Field(key: "bottomMax", emit_null: false)]
    property bottom_max : Int64?
    @[JSON::Field(key: "right", emit_null: false)]
    property right : Int64?
    @[JSON::Field(key: "rightMax", emit_null: false)]
    property right_max : Int64?

    def initialize(@top : Int64? = nil, @top_max : Int64? = nil, @left : Int64? = nil, @left_max : Int64? = nil, @bottom : Int64? = nil, @bottom_max : Int64? = nil, @right : Int64? = nil, @right_max : Int64? = nil)
    end
  end

  struct ScreenOrientation
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : OrientationType
    @[JSON::Field(key: "angle", emit_null: false)]
    property angle : Int64

    def initialize(@type : OrientationType, @angle : Int64)
    end
  end

  struct DisplayFeature
    include JSON::Serializable
    @[JSON::Field(key: "orientation", emit_null: false)]
    property orientation : DisplayFeatureOrientation
    @[JSON::Field(key: "offset", emit_null: false)]
    property offset : Int64
    @[JSON::Field(key: "maskLength", emit_null: false)]
    property mask_length : Int64

    def initialize(@orientation : DisplayFeatureOrientation, @offset : Int64, @mask_length : Int64)
    end
  end

  struct DevicePosture
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : DevicePostureType

    def initialize(@type : DevicePostureType)
    end
  end

  struct MediaFeature
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String

    def initialize(@name : String, @value : String)
    end
  end

  @[Experimental]
  alias VirtualTimePolicy = String
  VirtualTimePolicyAdvance                      = "advance"
  VirtualTimePolicyPause                        = "pause"
  VirtualTimePolicyPauseIfNetworkFetchesPending = "pauseIfNetworkFetchesPending"

  @[Experimental]
  struct UserAgentBrandVersion
    include JSON::Serializable
    @[JSON::Field(key: "brand", emit_null: false)]
    property brand : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String

    def initialize(@brand : String, @version : String)
    end
  end

  @[Experimental]
  struct UserAgentMetadata
    include JSON::Serializable
    @[JSON::Field(key: "brands", emit_null: false)]
    property brands : Array(UserAgentBrandVersion)?
    @[JSON::Field(key: "fullVersionList", emit_null: false)]
    property full_version_list : Array(UserAgentBrandVersion)?
    @[JSON::Field(key: "platform", emit_null: false)]
    property platform : String
    @[JSON::Field(key: "platformVersion", emit_null: false)]
    property platform_version : String
    @[JSON::Field(key: "architecture", emit_null: false)]
    property architecture : String
    @[JSON::Field(key: "model", emit_null: false)]
    property model : String
    @[JSON::Field(key: "mobile", emit_null: false)]
    property? mobile : Bool
    @[JSON::Field(key: "bitness", emit_null: false)]
    property bitness : String?
    @[JSON::Field(key: "wow64", emit_null: false)]
    property? wow64 : Bool?
    @[JSON::Field(key: "formFactors", emit_null: false)]
    property form_factors : Array(String)?

    def initialize(@platform : String, @platform_version : String, @architecture : String, @model : String, @mobile : Bool, @brands : Array(UserAgentBrandVersion)? = nil, @full_version_list : Array(UserAgentBrandVersion)? = nil, @bitness : String? = nil, @wow64 : Bool? = nil, @form_factors : Array(String)? = nil)
    end
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
    @[JSON::Field(key: "available", emit_null: false)]
    property? available : Bool?
    @[JSON::Field(key: "minimumFrequency", emit_null: false)]
    property minimum_frequency : Float64?
    @[JSON::Field(key: "maximumFrequency", emit_null: false)]
    property maximum_frequency : Float64?

    def initialize(@available : Bool? = nil, @minimum_frequency : Float64? = nil, @maximum_frequency : Float64? = nil)
    end
  end

  @[Experimental]
  struct SensorReadingSingle
    include JSON::Serializable
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Float64

    def initialize(@value : Float64)
    end
  end

  @[Experimental]
  struct SensorReadingXYZ
    include JSON::Serializable
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "z", emit_null: false)]
    property z : Float64

    def initialize(@x : Float64, @y : Float64, @z : Float64)
    end
  end

  @[Experimental]
  struct SensorReadingQuaternion
    include JSON::Serializable
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "z", emit_null: false)]
    property z : Float64
    @[JSON::Field(key: "w", emit_null: false)]
    property w : Float64

    def initialize(@x : Float64, @y : Float64, @z : Float64, @w : Float64)
    end
  end

  @[Experimental]
  struct SensorReading
    include JSON::Serializable
    @[JSON::Field(key: "single", emit_null: false)]
    property single : SensorReadingSingle?
    @[JSON::Field(key: "xyz", emit_null: false)]
    property xyz : SensorReadingXYZ?
    @[JSON::Field(key: "quaternion", emit_null: false)]
    property quaternion : SensorReadingQuaternion?

    def initialize(@single : SensorReadingSingle? = nil, @xyz : SensorReadingXYZ? = nil, @quaternion : SensorReadingQuaternion? = nil)
    end
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
    @[JSON::Field(key: "available", emit_null: false)]
    property? available : Bool?

    def initialize(@available : Bool? = nil)
    end
  end

  @[Experimental]
  struct WorkAreaInsets
    include JSON::Serializable
    @[JSON::Field(key: "top", emit_null: false)]
    property top : Int64?
    @[JSON::Field(key: "left", emit_null: false)]
    property left : Int64?
    @[JSON::Field(key: "bottom", emit_null: false)]
    property bottom : Int64?
    @[JSON::Field(key: "right", emit_null: false)]
    property right : Int64?

    def initialize(@top : Int64? = nil, @left : Int64? = nil, @bottom : Int64? = nil, @right : Int64? = nil)
    end
  end

  @[Experimental]
  alias ScreenId = String

  @[Experimental]
  struct ScreenInfo
    include JSON::Serializable
    @[JSON::Field(key: "left", emit_null: false)]
    property left : Int64
    @[JSON::Field(key: "top", emit_null: false)]
    property top : Int64
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Int64
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Int64
    @[JSON::Field(key: "availLeft", emit_null: false)]
    property avail_left : Int64
    @[JSON::Field(key: "availTop", emit_null: false)]
    property avail_top : Int64
    @[JSON::Field(key: "availWidth", emit_null: false)]
    property avail_width : Int64
    @[JSON::Field(key: "availHeight", emit_null: false)]
    property avail_height : Int64
    @[JSON::Field(key: "devicePixelRatio", emit_null: false)]
    property device_pixel_ratio : Float64
    @[JSON::Field(key: "orientation", emit_null: false)]
    property orientation : ScreenOrientation
    @[JSON::Field(key: "colorDepth", emit_null: false)]
    property color_depth : Int64
    @[JSON::Field(key: "isExtended", emit_null: false)]
    property? is_extended : Bool
    @[JSON::Field(key: "isInternal", emit_null: false)]
    property? is_internal : Bool
    @[JSON::Field(key: "isPrimary", emit_null: false)]
    property? is_primary : Bool
    @[JSON::Field(key: "label", emit_null: false)]
    property label : String
    @[JSON::Field(key: "id", emit_null: false)]
    property id : ScreenId

    def initialize(@left : Int64, @top : Int64, @width : Int64, @height : Int64, @avail_left : Int64, @avail_top : Int64, @avail_width : Int64, @avail_height : Int64, @device_pixel_ratio : Float64, @orientation : ScreenOrientation, @color_depth : Int64, @is_extended : Bool, @is_internal : Bool, @is_primary : Bool, @label : String, @id : ScreenId)
    end
  end

  @[Experimental]
  alias DisabledImageType = String
  DisabledImageTypeAvif = "avif"
  DisabledImageTypeJxl  = "jxl"
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

  alias SetDeviceMetricsOverrideScrollbarType = String
  SetDeviceMetricsOverrideScrollbarTypeOverlay = "overlay"
  SetDeviceMetricsOverrideScrollbarTypeDefault = "default"

  alias SetDeviceMetricsOverrideViewportMeta = String
  SetDeviceMetricsOverrideViewportMetaEnable  = "enable"
  SetDeviceMetricsOverrideViewportMetaDefault = "default"

  alias SetDeviceMetricsOverrideTextLayoutMode = String
  SetDeviceMetricsOverrideTextLayoutModeMobile  = "mobile"
  SetDeviceMetricsOverrideTextLayoutModeDefault = "default"

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

  alias SetCPUPerformanceOverridePerformanceTier = String
  SetCPUPerformanceOverridePerformanceTierUnknown = "unknown"
  SetCPUPerformanceOverridePerformanceTierLow     = "low"
  SetCPUPerformanceOverridePerformanceTierMid     = "mid"
  SetCPUPerformanceOverridePerformanceTierHigh    = "high"
  SetCPUPerformanceOverridePerformanceTierUltra   = "ultra"
end
