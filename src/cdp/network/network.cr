require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Network domain allows tracking network activities of the page. It exposes information about http,
# file, data and other requests and responses, their headers, bodies, timing, etc.
module Cdp::Network
  @[Experimental]
  struct EmulateNetworkConditionsByRuleResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule_ids : Array(String)

    def initialize(@rule_ids : Array(String))
    end
  end

  @[Experimental]
  struct GetCertificateResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property table_names : Array(String)

    def initialize(@table_names : Array(String))
    end
  end

  struct GetCookiesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cookies : Array(Cdp::NodeType)

    def initialize(@cookies : Array(Cdp::NodeType))
    end
  end

  struct GetResponseBodyResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property body : String
    @[JSON::Field(emit_null: false)]
    property? base64_encoded : Bool

    def initialize(@body : String, @base64_encoded : Bool)
    end
  end

  struct GetRequestPostDataResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property post_data : String
    @[JSON::Field(emit_null: false)]
    property? base64_encoded : Bool

    def initialize(@post_data : String, @base64_encoded : Bool)
    end
  end

  @[Experimental]
  struct GetResponseBodyForInterceptionResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property body : String
    @[JSON::Field(emit_null: false)]
    property? base64_encoded : Bool

    def initialize(@body : String, @base64_encoded : Bool)
    end
  end

  @[Experimental]
  struct TakeResponseBodyForInterceptionAsStreamResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::NodeType

    def initialize(@stream : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct SearchInResponseBodyResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property result : Array(Cdp::NodeType)

    def initialize(@result : Array(Cdp::NodeType))
    end
  end

  struct SetCookieResult
    include JSON::Serializable

    def initialize
    end
  end

  @[Experimental]
  struct StreamResourceContentResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property buffered_data : String

    def initialize(@buffered_data : String)
    end
  end

  @[Experimental]
  struct GetSecurityIsolationStatusResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType

    def initialize(@status : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct FetchSchemefulSiteResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property schemeful_site : String

    def initialize(@schemeful_site : String)
    end
  end

  @[Experimental]
  struct LoadNetworkResourceResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property resource : Cdp::NodeType

    def initialize(@resource : Cdp::NodeType)
    end
  end

  # Commands
  @[Experimental]
  struct SetAcceptedEncodings
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property encodings : Array(Cdp::NodeType)

    def initialize(@encodings : Array(Cdp::NodeType))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setAcceptedEncodings"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ClearAcceptedEncodingsOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.clearAcceptedEncodingsOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearBrowserCache
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.clearBrowserCache"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearBrowserCookies
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.clearBrowserCookies"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DeleteCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property domain : String?
    @[JSON::Field(emit_null: false)]
    property path : String?
    @[JSON::Field(emit_null: false)]
    property partition_key : Cdp::NodeType?

    def initialize(@name : String, @url : String?, @domain : String?, @path : String?, @partition_key : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.deleteCookies"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct EmulateNetworkConditionsByRule
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? offline : Bool
    @[JSON::Field(emit_null: false)]
    property matched_network_conditions : Array(Cdp::NodeType)

    def initialize(@offline : Bool, @matched_network_conditions : Array(Cdp::NodeType))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.emulateNetworkConditionsByRule"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : EmulateNetworkConditionsByRuleResult
      res = EmulateNetworkConditionsByRuleResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct OverrideNetworkState
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? offline : Bool
    @[JSON::Field(emit_null: false)]
    property latency : Float64
    @[JSON::Field(emit_null: false)]
    property download_throughput : Float64
    @[JSON::Field(emit_null: false)]
    property upload_throughput : Float64
    @[JSON::Field(emit_null: false)]
    property connection_type : Cdp::NodeType?

    def initialize(@offline : Bool, @latency : Float64, @download_throughput : Float64, @upload_throughput : Float64, @connection_type : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.overrideNetworkState"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property max_total_buffer_size : Int64?
    @[JSON::Field(emit_null: false)]
    property max_resource_buffer_size : Int64?
    @[JSON::Field(emit_null: false)]
    property max_post_data_size : Int64?
    @[JSON::Field(emit_null: false)]
    property? report_direct_socket_traffic : Bool?
    @[JSON::Field(emit_null: false)]
    property? enable_durable_messages : Bool?

    def initialize(@max_total_buffer_size : Int64?, @max_resource_buffer_size : Int64?, @max_post_data_size : Int64?, @report_direct_socket_traffic : Bool?, @enable_durable_messages : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ConfigureDurableMessages
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property max_total_buffer_size : Int64?
    @[JSON::Field(emit_null: false)]
    property max_resource_buffer_size : Int64?

    def initialize(@max_total_buffer_size : Int64?, @max_resource_buffer_size : Int64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.configureDurableMessages"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetCertificate
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.getCertificate"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCertificateResult
      res = GetCertificateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property urls : Array(String)?

    def initialize(@urls : Array(String)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.getCookies"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCookiesResult
      res = GetCookiesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetResponseBody
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.getResponseBody"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetResponseBodyResult
      res = GetResponseBodyResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetRequestPostData
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.getRequestPostData"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetRequestPostDataResult
      res = GetRequestPostDataResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetResponseBodyForInterception
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property interception_id : Cdp::NodeType

    def initialize(@interception_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.getResponseBodyForInterception"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetResponseBodyForInterceptionResult
      res = GetResponseBodyForInterceptionResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct TakeResponseBodyForInterceptionAsStream
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property interception_id : Cdp::NodeType

    def initialize(@interception_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.takeResponseBodyForInterceptionAsStream"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : TakeResponseBodyForInterceptionAsStreamResult
      res = TakeResponseBodyForInterceptionAsStreamResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct ReplayXHR
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.replayXHR"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SearchInResponseBody
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property query : String
    @[JSON::Field(emit_null: false)]
    property? case_sensitive : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_regex : Bool?

    def initialize(@request_id : Cdp::NodeType, @query : String, @case_sensitive : Bool?, @is_regex : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.searchInResponseBody"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SearchInResponseBodyResult
      res = SearchInResponseBodyResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetBlockedURLs
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property url_patterns : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property urls : Array(String)?

    def initialize(@url_patterns : Array(Cdp::NodeType)?, @urls : Array(String)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setBlockedURLs"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetBypassServiceWorker
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? bypass : Bool

    def initialize(@bypass : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setBypassServiceWorker"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetCacheDisabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? cache_disabled : Bool

    def initialize(@cache_disabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setCacheDisabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetCookie
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property domain : String?
    @[JSON::Field(emit_null: false)]
    property path : String?
    @[JSON::Field(emit_null: false)]
    property? secure : Bool?
    @[JSON::Field(emit_null: false)]
    property? http_only : Bool?
    @[JSON::Field(emit_null: false)]
    property same_site : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property expires : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property priority : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_scheme : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_port : Int64?
    @[JSON::Field(emit_null: false)]
    property partition_key : Cdp::NodeType?

    def initialize(@name : String, @value : String, @url : String?, @domain : String?, @path : String?, @secure : Bool?, @http_only : Bool?, @same_site : Cdp::NodeType?, @expires : Cdp::NodeType?, @priority : Cdp::NodeType?, @source_scheme : Cdp::NodeType?, @source_port : Int64?, @partition_key : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setCookie"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetCookieResult
      res = SetCookieResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cookies : Array(Cdp::NodeType)

    def initialize(@cookies : Array(Cdp::NodeType))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setCookies"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetExtraHTTPHeaders
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType

    def initialize(@headers : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setExtraHTTPHeaders"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetAttachDebugStack
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setAttachDebugStack"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct StreamResourceContent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.streamResourceContent"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : StreamResourceContentResult
      res = StreamResourceContentResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetSecurityIsolationStatus
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?

    def initialize(@frame_id : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.getSecurityIsolationStatus"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSecurityIsolationStatusResult
      res = GetSecurityIsolationStatusResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct EnableReportingApi
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.enableReportingApi"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct EnableDeviceBoundSessions
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.enableDeviceBoundSessions"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct FetchSchemefulSite
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.fetchSchemefulSite"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : FetchSchemefulSiteResult
      res = FetchSchemefulSiteResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct LoadNetworkResource
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property options : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType?, @url : String, @options : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.loadNetworkResource"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : LoadNetworkResourceResult
      res = LoadNetworkResourceResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetCookieControls
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable_third_party_cookie_restriction : Bool
    @[JSON::Field(emit_null: false)]
    property? disable_third_party_cookie_metadata : Bool
    @[JSON::Field(emit_null: false)]
    property? disable_third_party_cookie_heuristics : Bool

    def initialize(@enable_third_party_cookie_restriction : Bool, @disable_third_party_cookie_metadata : Bool, @disable_third_party_cookie_heuristics : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Network.setCookieControls"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
