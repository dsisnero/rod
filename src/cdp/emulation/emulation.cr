require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../network/network"

require "./types"
require "./events"

# This domain emulates different environments for the page.
module Cdp::Emulation
  @[Experimental]
  struct GetOverriddenSensorInformationResult
    include JSON::Serializable
    @[JSON::Field(key: "requestedSamplingFrequency", emit_null: false)]
    property requested_sampling_frequency : Float64

    def initialize(@requested_sampling_frequency : Float64)
    end
  end

  @[Experimental]
  struct SetVirtualTimePolicyResult
    include JSON::Serializable
    @[JSON::Field(key: "virtualTimeTicksBase", emit_null: false)]
    property virtual_time_ticks_base : Float64

    def initialize(@virtual_time_ticks_base : Float64)
    end
  end

  @[Experimental]
  struct GetScreenInfosResult
    include JSON::Serializable
    @[JSON::Field(key: "screenInfos", emit_null: false)]
    property screen_infos : Array(ScreenInfo)

    def initialize(@screen_infos : Array(ScreenInfo))
    end
  end

  @[Experimental]
  struct AddScreenResult
    include JSON::Serializable
    @[JSON::Field(key: "screenInfo", emit_null: false)]
    property screen_info : ScreenInfo

    def initialize(@screen_info : ScreenInfo)
    end
  end

  # Commands
  struct ClearDeviceMetricsOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.clearDeviceMetricsOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearGeolocationOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.clearGeolocationOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ResetPageScaleFactor
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.resetPageScaleFactor"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetFocusEmulationEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setFocusEmulationEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetAutoDarkModeOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool?

    def initialize(@enabled : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setAutoDarkModeOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetCPUThrottlingRate
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "rate", emit_null: false)]
    property rate : Float64

    def initialize(@rate : Float64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setCPUThrottlingRate"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDefaultBackgroundColorOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "color", emit_null: false)]
    property color : Cdp::DOM::RGBA?

    def initialize(@color : Cdp::DOM::RGBA?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDefaultBackgroundColorOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetSafeAreaInsetsOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "insets", emit_null: false)]
    property insets : SafeAreaInsets

    def initialize(@insets : SafeAreaInsets)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setSafeAreaInsetsOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDeviceMetricsOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Int64
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Int64
    @[JSON::Field(key: "deviceScaleFactor", emit_null: false)]
    property device_scale_factor : Float64
    @[JSON::Field(key: "mobile", emit_null: false)]
    property? mobile : Bool
    @[JSON::Field(key: "scale", emit_null: false)]
    property scale : Float64?
    @[JSON::Field(key: "screenWidth", emit_null: false)]
    property screen_width : Int64?
    @[JSON::Field(key: "screenHeight", emit_null: false)]
    property screen_height : Int64?
    @[JSON::Field(key: "positionX", emit_null: false)]
    property position_x : Int64?
    @[JSON::Field(key: "positionY", emit_null: false)]
    property position_y : Int64?
    @[JSON::Field(key: "dontSetVisibleSize", emit_null: false)]
    property? dont_set_visible_size : Bool?
    @[JSON::Field(key: "screenOrientation", emit_null: false)]
    property screen_orientation : ScreenOrientation?
    @[JSON::Field(key: "viewport", emit_null: false)]
    property viewport : Cdp::Page::Viewport?
    @[JSON::Field(key: "displayFeature", emit_null: false)]
    property display_feature : DisplayFeature?
    @[JSON::Field(key: "devicePosture", emit_null: false)]
    property device_posture : DevicePosture?

    def initialize(@width : Int64, @height : Int64, @device_scale_factor : Float64, @mobile : Bool, @scale : Float64?, @screen_width : Int64?, @screen_height : Int64?, @position_x : Int64?, @position_y : Int64?, @dont_set_visible_size : Bool?, @screen_orientation : ScreenOrientation?, @viewport : Cdp::Page::Viewport?, @display_feature : DisplayFeature?, @device_posture : DevicePosture?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDeviceMetricsOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDevicePostureOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "posture", emit_null: false)]
    property posture : DevicePosture

    def initialize(@posture : DevicePosture)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDevicePostureOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ClearDevicePostureOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.clearDevicePostureOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDisplayFeaturesOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "features", emit_null: false)]
    property features : Array(DisplayFeature)

    def initialize(@features : Array(DisplayFeature))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDisplayFeaturesOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ClearDisplayFeaturesOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.clearDisplayFeaturesOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetScrollbarsHidden
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "hidden", emit_null: false)]
    property? hidden : Bool

    def initialize(@hidden : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setScrollbarsHidden"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDocumentCookieDisabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "disabled", emit_null: false)]
    property? disabled : Bool

    def initialize(@disabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDocumentCookieDisabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetEmitTouchEventsForMouse
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool
    @[JSON::Field(key: "configuration", emit_null: false)]
    property configuration : SetEmitTouchEventsForMouseConfiguration?

    def initialize(@enabled : Bool, @configuration : SetEmitTouchEventsForMouseConfiguration?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setEmitTouchEventsForMouse"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetEmulatedMedia
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "media", emit_null: false)]
    property media : String?
    @[JSON::Field(key: "features", emit_null: false)]
    property features : Array(MediaFeature)?

    def initialize(@media : String?, @features : Array(MediaFeature)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setEmulatedMedia"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetEmulatedVisionDeficiency
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : SetEmulatedVisionDeficiencyType

    def initialize(@type : SetEmulatedVisionDeficiencyType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setEmulatedVisionDeficiency"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetEmulatedOSTextScale
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "scale", emit_null: false)]
    property scale : Float64?

    def initialize(@scale : Float64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setEmulatedOSTextScale"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetGeolocationOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "latitude", emit_null: false)]
    property latitude : Float64?
    @[JSON::Field(key: "longitude", emit_null: false)]
    property longitude : Float64?
    @[JSON::Field(key: "accuracy", emit_null: false)]
    property accuracy : Float64?
    @[JSON::Field(key: "altitude", emit_null: false)]
    property altitude : Float64?
    @[JSON::Field(key: "altitudeAccuracy", emit_null: false)]
    property altitude_accuracy : Float64?
    @[JSON::Field(key: "heading", emit_null: false)]
    property heading : Float64?
    @[JSON::Field(key: "speed", emit_null: false)]
    property speed : Float64?

    def initialize(@latitude : Float64?, @longitude : Float64?, @accuracy : Float64?, @altitude : Float64?, @altitude_accuracy : Float64?, @heading : Float64?, @speed : Float64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setGeolocationOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetOverriddenSensorInformation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : SensorType

    def initialize(@type : SensorType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.getOverriddenSensorInformation"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetOverriddenSensorInformationResult
      res = GetOverriddenSensorInformationResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetSensorOverrideEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool
    @[JSON::Field(key: "type", emit_null: false)]
    property type : SensorType
    @[JSON::Field(key: "metadata", emit_null: false)]
    property metadata : SensorMetadata?

    def initialize(@enabled : Bool, @type : SensorType, @metadata : SensorMetadata?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setSensorOverrideEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetSensorOverrideReadings
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "type", emit_null: false)]
    property type : SensorType
    @[JSON::Field(key: "reading", emit_null: false)]
    property reading : SensorReading

    def initialize(@type : SensorType, @reading : SensorReading)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setSensorOverrideReadings"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetPressureSourceOverrideEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool
    @[JSON::Field(key: "source", emit_null: false)]
    property source : PressureSource
    @[JSON::Field(key: "metadata", emit_null: false)]
    property metadata : PressureMetadata?

    def initialize(@enabled : Bool, @source : PressureSource, @metadata : PressureMetadata?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setPressureSourceOverrideEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetPressureStateOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "source", emit_null: false)]
    property source : PressureSource
    @[JSON::Field(key: "state", emit_null: false)]
    property state : PressureState

    def initialize(@source : PressureSource, @state : PressureState)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setPressureStateOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetPressureDataOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "source", emit_null: false)]
    property source : PressureSource
    @[JSON::Field(key: "state", emit_null: false)]
    property state : PressureState
    @[JSON::Field(key: "ownContributionEstimate", emit_null: false)]
    property own_contribution_estimate : Float64?

    def initialize(@source : PressureSource, @state : PressureState, @own_contribution_estimate : Float64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setPressureDataOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetIdleOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "isUserActive", emit_null: false)]
    property? is_user_active : Bool
    @[JSON::Field(key: "isScreenUnlocked", emit_null: false)]
    property? is_screen_unlocked : Bool

    def initialize(@is_user_active : Bool, @is_screen_unlocked : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setIdleOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearIdleOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.clearIdleOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetPageScaleFactor
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "pageScaleFactor", emit_null: false)]
    property page_scale_factor : Float64

    def initialize(@page_scale_factor : Float64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setPageScaleFactor"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetScriptExecutionDisabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "value", emit_null: false)]
    property? value : Bool

    def initialize(@value : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setScriptExecutionDisabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetTouchEmulationEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool
    @[JSON::Field(key: "maxTouchPoints", emit_null: false)]
    property max_touch_points : Int64?

    def initialize(@enabled : Bool, @max_touch_points : Int64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setTouchEmulationEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetVirtualTimePolicy
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "policy", emit_null: false)]
    property policy : VirtualTimePolicy
    @[JSON::Field(key: "budget", emit_null: false)]
    property budget : Float64?
    @[JSON::Field(key: "maxVirtualTimeTaskStarvationCount", emit_null: false)]
    property max_virtual_time_task_starvation_count : Int64?
    @[JSON::Field(key: "initialVirtualTime", emit_null: false)]
    property initial_virtual_time : Cdp::Network::TimeSinceEpoch?

    def initialize(@policy : VirtualTimePolicy, @budget : Float64?, @max_virtual_time_task_starvation_count : Int64?, @initial_virtual_time : Cdp::Network::TimeSinceEpoch?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setVirtualTimePolicy"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetVirtualTimePolicyResult
      res = SetVirtualTimePolicyResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetLocaleOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "locale", emit_null: false)]
    property locale : String?

    def initialize(@locale : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setLocaleOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetTimezoneOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "timezoneId", emit_null: false)]
    property timezone_id : String

    def initialize(@timezone_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setTimezoneOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDisabledImageTypes
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "imageTypes", emit_null: false)]
    property image_types : Array(DisabledImageType)

    def initialize(@image_types : Array(DisabledImageType))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDisabledImageTypes"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDataSaverOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "dataSaverEnabled", emit_null: false)]
    property? data_saver_enabled : Bool?

    def initialize(@data_saver_enabled : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setDataSaverOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetHardwareConcurrencyOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "hardwareConcurrency", emit_null: false)]
    property hardware_concurrency : Int64

    def initialize(@hardware_concurrency : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setHardwareConcurrencyOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetUserAgentOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "userAgent", emit_null: false)]
    property user_agent : String
    @[JSON::Field(key: "acceptLanguage", emit_null: false)]
    property accept_language : String?
    @[JSON::Field(key: "platform", emit_null: false)]
    property platform : String?
    @[JSON::Field(key: "userAgentMetadata", emit_null: false)]
    property user_agent_metadata : UserAgentMetadata?

    def initialize(@user_agent : String, @accept_language : String?, @platform : String?, @user_agent_metadata : UserAgentMetadata?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setUserAgentOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetAutomationOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setAutomationOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetSmallViewportHeightDifferenceOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "difference", emit_null: false)]
    property difference : Int64

    def initialize(@difference : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.setSmallViewportHeightDifferenceOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetScreenInfos
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.getScreenInfos"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetScreenInfosResult
      res = GetScreenInfosResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct AddScreen
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "left", emit_null: false)]
    property left : Int64
    @[JSON::Field(key: "top", emit_null: false)]
    property top : Int64
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Int64
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Int64
    @[JSON::Field(key: "workAreaInsets", emit_null: false)]
    property work_area_insets : WorkAreaInsets?
    @[JSON::Field(key: "devicePixelRatio", emit_null: false)]
    property device_pixel_ratio : Float64?
    @[JSON::Field(key: "rotation", emit_null: false)]
    property rotation : Int64?
    @[JSON::Field(key: "colorDepth", emit_null: false)]
    property color_depth : Int64?
    @[JSON::Field(key: "label", emit_null: false)]
    property label : String?
    @[JSON::Field(key: "isInternal", emit_null: false)]
    property? is_internal : Bool?

    def initialize(@left : Int64, @top : Int64, @width : Int64, @height : Int64, @work_area_insets : WorkAreaInsets?, @device_pixel_ratio : Float64?, @rotation : Int64?, @color_depth : Int64?, @label : String?, @is_internal : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.addScreen"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddScreenResult
      res = AddScreenResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct RemoveScreen
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "screenId", emit_null: false)]
    property screen_id : ScreenId

    def initialize(@screen_id : ScreenId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Emulation.removeScreen"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
