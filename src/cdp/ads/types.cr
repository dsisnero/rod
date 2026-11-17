require "../cdp"
require "json"
require "base64"
require "time"

require "../page/page"
require "../runtime/runtime"
require "../network/network"

module Cdp::Ads
  struct AdFrameData
    include JSON::Serializable
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "initialOrigin", emit_null: false)]
    property initial_origin : String?
    @[JSON::Field(key: "networkBytes", emit_null: false)]
    property network_bytes : Float64
    @[JSON::Field(key: "cpuTime", emit_null: false)]
    property cpu_time : Float64

    def initialize(@frame_id : Cdp::Page::FrameId, @network_bytes : Float64, @cpu_time : Float64, @initial_origin : String? = nil)
    end
  end

  struct AdMetrics
    include JSON::Serializable
    @[JSON::Field(key: "viewportAdDensityByArea", emit_null: false)]
    property viewport_ad_density_by_area : Int64
    @[JSON::Field(key: "averageViewportAdDensityByArea", emit_null: false)]
    property average_viewport_ad_density_by_area : Float64
    @[JSON::Field(key: "viewportAdCount", emit_null: false)]
    property viewport_ad_count : Int64
    @[JSON::Field(key: "averageViewportAdCount", emit_null: false)]
    property average_viewport_ad_count : Float64
    @[JSON::Field(key: "totalAdCpuTime", emit_null: false)]
    property total_ad_cpu_time : Float64
    @[JSON::Field(key: "totalAdNetworkBytes", emit_null: false)]
    property total_ad_network_bytes : Float64
    @[JSON::Field(key: "updateAdFrames", emit_null: false)]
    property update_ad_frames : Array(AdFrameData)
    @[JSON::Field(key: "removeAdFrames", emit_null: false)]
    property remove_ad_frames : Array(Cdp::Page::FrameId)

    def initialize(@viewport_ad_density_by_area : Int64, @average_viewport_ad_density_by_area : Float64, @viewport_ad_count : Int64, @average_viewport_ad_count : Float64, @total_ad_cpu_time : Float64, @total_ad_network_bytes : Float64, @update_ad_frames : Array(AdFrameData), @remove_ad_frames : Array(Cdp::Page::FrameId))
    end
  end

  struct AdScript
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(key: "provenance", emit_null: false)]
    property provenance : Cdp::Network::AdProvenance

    def initialize(@script_id : Cdp::Runtime::ScriptId, @provenance : Cdp::Network::AdProvenance)
    end
  end
end
