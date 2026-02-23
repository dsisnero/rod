
require "../cdp"
require "json"
require "time"


module Cdp::SystemInfo
  struct GPUDevice
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property vendor_id : Float64
    @[JSON::Field(emit_null: false)]
    property device_id : Float64
    @[JSON::Field(emit_null: false)]
    property sub_sys_id : Float64?
    @[JSON::Field(emit_null: false)]
    property revision : Float64?
    @[JSON::Field(emit_null: false)]
    property vendor_string : String
    @[JSON::Field(emit_null: false)]
    property device_string : String
    @[JSON::Field(emit_null: false)]
    property driver_vendor : String
    @[JSON::Field(emit_null: false)]
    property driver_version : String
  end

  struct Size
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property width : Int64
    @[JSON::Field(emit_null: false)]
    property height : Int64
  end

  struct VideoDecodeAcceleratorCapability
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property profile : String
    @[JSON::Field(emit_null: false)]
    property max_resolution : Size
    @[JSON::Field(emit_null: false)]
    property min_resolution : Size
  end

  struct VideoEncodeAcceleratorCapability
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property profile : String
    @[JSON::Field(emit_null: false)]
    property max_resolution : Size
    @[JSON::Field(emit_null: false)]
    property max_framerate_numerator : Int64
    @[JSON::Field(emit_null: false)]
    property max_framerate_denominator : Int64
  end

  alias SubsamplingFormat = String

  alias ImageType = String

  struct GPUInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property devices : Array(GPUDevice)
    @[JSON::Field(emit_null: false)]
    property aux_attributes : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property feature_status : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property driver_bug_workarounds : Array(String)
    @[JSON::Field(emit_null: false)]
    property video_decoding : Array(VideoDecodeAcceleratorCapability)
    @[JSON::Field(emit_null: false)]
    property video_encoding : Array(VideoEncodeAcceleratorCapability)
  end

  struct ProcessInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : String
    @[JSON::Field(emit_null: false)]
    property id : Int64
    @[JSON::Field(emit_null: false)]
    property cpu_time : Float64
  end

   end
