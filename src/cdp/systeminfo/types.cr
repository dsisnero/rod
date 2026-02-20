require "../systeminfo/systeminfo"
require "json"
require "time"

module Cdp::SystemInfo
  struct GPUDevice
    include JSON::Serializable

    property vendor_id : Float64
    property device_id : Float64
    @[JSON::Field(emit_null: false)]
    property sub_sys_id : Float64?
    @[JSON::Field(emit_null: false)]
    property revision : Float64?
    property vendor_string : String
    property device_string : String
    property driver_vendor : String
    property driver_version : String
  end

  struct Size
    include JSON::Serializable

    property width : Int64
    property height : Int64
  end

  struct VideoDecodeAcceleratorCapability
    include JSON::Serializable

    property profile : String
    property max_resolution : Size
    property min_resolution : Size
  end

  struct VideoEncodeAcceleratorCapability
    include JSON::Serializable

    property profile : String
    property max_resolution : Size
    property max_framerate_numerator : Int64
    property max_framerate_denominator : Int64
  end

  alias SubsamplingFormat = String

  alias ImageType = String

  struct GPUInfo
    include JSON::Serializable

    property devices : Array(GPUDevice)
    @[JSON::Field(emit_null: false)]
    property aux_attributes : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property feature_status : JSON::Any?
    property driver_bug_workarounds : Array(String)
    property video_decoding : Array(VideoDecodeAcceleratorCapability)
    property video_encoding : Array(VideoEncodeAcceleratorCapability)
  end

  struct ProcessInfo
    include JSON::Serializable

    property type : String
    property id : Int64
    property cpu_time : Float64
  end
end
