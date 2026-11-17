require "../cdp"
require "json"
require "base64"
require "time"

module Cdp::SystemInfo
  struct GPUDevice
    include JSON::Serializable
    @[JSON::Field(key: "vendorId", emit_null: false)]
    property vendor_id : Float64
    @[JSON::Field(key: "deviceId", emit_null: false)]
    property device_id : Float64
    @[JSON::Field(key: "subSysId", emit_null: false)]
    property sub_sys_id : Float64?
    @[JSON::Field(key: "revision", emit_null: false)]
    property revision : Float64?
    @[JSON::Field(key: "vendorString", emit_null: false)]
    property vendor_string : String
    @[JSON::Field(key: "deviceString", emit_null: false)]
    property device_string : String
    @[JSON::Field(key: "driverVendor", emit_null: false)]
    property driver_vendor : String
    @[JSON::Field(key: "driverVersion", emit_null: false)]
    property driver_version : String

    def initialize(@vendor_id : Float64, @device_id : Float64, @vendor_string : String, @device_string : String, @driver_vendor : String, @driver_version : String, @sub_sys_id : Float64? = nil, @revision : Float64? = nil)
    end
  end

  struct Size
    include JSON::Serializable
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Int64
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Int64

    def initialize(@width : Int64, @height : Int64)
    end
  end

  struct VideoDecodeAcceleratorCapability
    include JSON::Serializable
    @[JSON::Field(key: "profile", emit_null: false)]
    property profile : String
    @[JSON::Field(key: "maxResolution", emit_null: false)]
    property max_resolution : Size
    @[JSON::Field(key: "minResolution", emit_null: false)]
    property min_resolution : Size

    def initialize(@profile : String, @max_resolution : Size, @min_resolution : Size)
    end
  end

  struct VideoEncodeAcceleratorCapability
    include JSON::Serializable
    @[JSON::Field(key: "profile", emit_null: false)]
    property profile : String
    @[JSON::Field(key: "maxResolution", emit_null: false)]
    property max_resolution : Size
    @[JSON::Field(key: "maxFramerateNumerator", emit_null: false)]
    property max_framerate_numerator : Int64
    @[JSON::Field(key: "maxFramerateDenominator", emit_null: false)]
    property max_framerate_denominator : Int64

    def initialize(@profile : String, @max_resolution : Size, @max_framerate_numerator : Int64, @max_framerate_denominator : Int64)
    end
  end

  alias SubsamplingFormat = String
  SubsamplingFormatYuv420 = "yuv420"
  SubsamplingFormatYuv422 = "yuv422"
  SubsamplingFormatYuv444 = "yuv444"

  alias ImageType = String
  ImageTypeJpeg    = "jpeg"
  ImageTypeWebp    = "webp"
  ImageTypeUnknown = "unknown"

  struct GPUInfo
    include JSON::Serializable
    @[JSON::Field(key: "devices", emit_null: false)]
    property devices : Array(GPUDevice)
    @[JSON::Field(key: "auxAttributes", emit_null: false)]
    property aux_attributes : JSON::Any?
    @[JSON::Field(key: "featureStatus", emit_null: false)]
    property feature_status : JSON::Any?
    @[JSON::Field(key: "driverBugWorkarounds", emit_null: false)]
    property driver_bug_workarounds : Array(String)
    @[JSON::Field(key: "videoDecoding", emit_null: false)]
    property video_decoding : Array(VideoDecodeAcceleratorCapability)
    @[JSON::Field(key: "videoEncoding", emit_null: false)]
    property video_encoding : Array(VideoEncodeAcceleratorCapability)

    def initialize(@devices : Array(GPUDevice), @driver_bug_workarounds : Array(String), @video_decoding : Array(VideoDecodeAcceleratorCapability), @video_encoding : Array(VideoEncodeAcceleratorCapability), @aux_attributes : JSON::Any? = nil, @feature_status : JSON::Any? = nil)
    end
  end

  struct ProcessInfo
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String
    @[JSON::Field(key: "id", emit_null: false)]
    property id : Int64
    @[JSON::Field(key: "cpuTime", emit_null: false)]
    property cpu_time : Float64

    def initialize(@type : String, @id : Int64, @cpu_time : Float64)
    end
  end
end
