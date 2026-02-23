
require "../cdp"
require "json"
require "time"

require "../security/security"
require "../runtime/runtime"
require "../io/io"
require "../debugger/debugger"
require "../page/page"

module Cdp::Network
  struct DataReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property data_length : Int64
    @[JSON::Field(emit_null: false)]
    property encoded_data_length : Int64
    @[JSON::Field(emit_null: false)]
    property data : String?

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @data_length : Int64, @encoded_data_length : Int64, @data : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.dataReceived"
    end
  end

  struct EventSourceMessageReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property event_name : String
    @[JSON::Field(emit_null: false)]
    property event_id : String
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @event_name : String, @event_id : String, @data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.eventSourceMessageReceived"
    end
  end

  struct LoadingFailedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property type : ResourceType
    @[JSON::Field(emit_null: false)]
    property error_text : String
    @[JSON::Field(emit_null: false)]
    property canceled : Bool?
    @[JSON::Field(emit_null: false)]
    property blocked_reason : BlockedReason?
    @[JSON::Field(emit_null: false)]
    property cors_error_status : CorsErrorStatus?

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @type : ResourceType, @error_text : String, @canceled : Bool?, @blocked_reason : BlockedReason?, @cors_error_status : CorsErrorStatus?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.loadingFailed"
    end
  end

  struct LoadingFinishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property encoded_data_length : Float64

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @encoded_data_length : Float64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.loadingFinished"
    end
  end

  struct RequestServedFromCacheEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId

    def initialize(@request_id : RequestId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.requestServedFromCache"
    end
  end

  struct RequestWillBeSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property loader_id : LoaderId
    @[JSON::Field(emit_null: false)]
    property document_url : String
    @[JSON::Field(emit_null: false)]
    property request : Request
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property wall_time : TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property initiator : Initiator
    @[JSON::Field(emit_null: false)]
    property redirect_has_extra_info : Bool
    @[JSON::Field(emit_null: false)]
    property redirect_response : Response?
    @[JSON::Field(emit_null: false)]
    property type : ResourceType?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
    @[JSON::Field(emit_null: false)]
    property has_user_gesture : Bool?
    @[JSON::Field(emit_null: false)]
    property render_blocking_behavior : RenderBlockingBehavior?

    def initialize(@request_id : RequestId, @loader_id : LoaderId, @document_url : String, @request : Request, @timestamp : MonotonicTime, @wall_time : TimeSinceEpoch, @initiator : Initiator, @redirect_has_extra_info : Bool, @redirect_response : Response?, @type : ResourceType?, @frame_id : Cdp::Page::FrameId?, @has_user_gesture : Bool?, @render_blocking_behavior : RenderBlockingBehavior?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.requestWillBeSent"
    end
  end

  @[Experimental]
  struct ResourceChangedPriorityEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property new_priority : ResourcePriority
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@request_id : RequestId, @new_priority : ResourcePriority, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.resourceChangedPriority"
    end
  end

  @[Experimental]
  struct SignedExchangeReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property info : SignedExchangeInfo

    def initialize(@request_id : RequestId, @info : SignedExchangeInfo)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.signedExchangeReceived"
    end
  end

  struct ResponseReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property loader_id : LoaderId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property type : ResourceType
    @[JSON::Field(emit_null: false)]
    property response : Response
    @[JSON::Field(emit_null: false)]
    property has_extra_info : Bool
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?

    def initialize(@request_id : RequestId, @loader_id : LoaderId, @timestamp : MonotonicTime, @type : ResourceType, @response : Response, @has_extra_info : Bool, @frame_id : Cdp::Page::FrameId?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.responseReceived"
    end
  end

  struct WebSocketClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketClosed"
    end
  end

  struct WebSocketCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property initiator : Initiator?

    def initialize(@request_id : RequestId, @url : String, @initiator : Initiator?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketCreated"
    end
  end

  struct WebSocketFrameErrorEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property error_message : String

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @error_message : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketFrameError"
    end
  end

  struct WebSocketFrameReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property response : WebSocketFrame

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @response : WebSocketFrame)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketFrameReceived"
    end
  end

  struct WebSocketFrameSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property response : WebSocketFrame

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @response : WebSocketFrame)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketFrameSent"
    end
  end

  struct WebSocketHandshakeResponseReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property response : WebSocketResponse

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @response : WebSocketResponse)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketHandshakeResponseReceived"
    end
  end

  struct WebSocketWillSendHandshakeRequestEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property wall_time : TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property request : WebSocketRequest

    def initialize(@request_id : RequestId, @timestamp : MonotonicTime, @wall_time : TimeSinceEpoch, @request : WebSocketRequest)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketWillSendHandshakeRequest"
    end
  end

  struct WebTransportCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property transport_id : RequestId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property initiator : Initiator?

    def initialize(@transport_id : RequestId, @url : String, @timestamp : MonotonicTime, @initiator : Initiator?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webTransportCreated"
    end
  end

  struct WebTransportConnectionEstablishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property transport_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@transport_id : RequestId, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webTransportConnectionEstablished"
    end
  end

  struct WebTransportClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property transport_id : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@transport_id : RequestId, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webTransportClosed"
    end
  end

  @[Experimental]
  struct DirectTCPSocketCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property remote_addr : String
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64
    @[JSON::Field(emit_null: false)]
    property options : DirectTCPSocketOptions
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property initiator : Initiator?

    def initialize(@identifier : RequestId, @remote_addr : String, @remote_port : Int64, @options : DirectTCPSocketOptions, @timestamp : MonotonicTime, @initiator : Initiator?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketCreated"
    end
  end

  @[Experimental]
  struct DirectTCPSocketOpenedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property remote_addr : String
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property local_addr : String?
    @[JSON::Field(emit_null: false)]
    property local_port : Int64?

    def initialize(@identifier : RequestId, @remote_addr : String, @remote_port : Int64, @timestamp : MonotonicTime, @local_addr : String?, @local_port : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketOpened"
    end
  end

  @[Experimental]
  struct DirectTCPSocketAbortedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property error_message : String
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @error_message : String, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketAborted"
    end
  end

  @[Experimental]
  struct DirectTCPSocketClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketClosed"
    end
  end

  @[Experimental]
  struct DirectTCPSocketChunkSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @data : String, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketChunkSent"
    end
  end

  @[Experimental]
  struct DirectTCPSocketChunkReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @data : String, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketChunkReceived"
    end
  end

  @[Experimental]
  struct DirectUDPSocketJoinedMulticastGroupEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property ip_address : String

    def initialize(@identifier : RequestId, @ip_address : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketJoinedMulticastGroup"
    end
  end

  @[Experimental]
  struct DirectUDPSocketLeftMulticastGroupEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property ip_address : String

    def initialize(@identifier : RequestId, @ip_address : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketLeftMulticastGroup"
    end
  end

  @[Experimental]
  struct DirectUDPSocketCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property options : DirectUDPSocketOptions
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property initiator : Initiator?

    def initialize(@identifier : RequestId, @options : DirectUDPSocketOptions, @timestamp : MonotonicTime, @initiator : Initiator?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketCreated"
    end
  end

  @[Experimental]
  struct DirectUDPSocketOpenedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property local_addr : String
    @[JSON::Field(emit_null: false)]
    property local_port : Int64
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime
    @[JSON::Field(emit_null: false)]
    property remote_addr : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?

    def initialize(@identifier : RequestId, @local_addr : String, @local_port : Int64, @timestamp : MonotonicTime, @remote_addr : String?, @remote_port : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketOpened"
    end
  end

  @[Experimental]
  struct DirectUDPSocketAbortedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property error_message : String
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @error_message : String, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketAborted"
    end
  end

  @[Experimental]
  struct DirectUDPSocketClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketClosed"
    end
  end

  @[Experimental]
  struct DirectUDPSocketChunkSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property message : DirectUDPMessage
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @message : DirectUDPMessage, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketChunkSent"
    end
  end

  @[Experimental]
  struct DirectUDPSocketChunkReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : RequestId
    @[JSON::Field(emit_null: false)]
    property message : DirectUDPMessage
    @[JSON::Field(emit_null: false)]
    property timestamp : MonotonicTime

    def initialize(@identifier : RequestId, @message : DirectUDPMessage, @timestamp : MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketChunkReceived"
    end
  end

  @[Experimental]
  struct RequestWillBeSentExtraInfoEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property associated_cookies : Array(AssociatedCookie)
    @[JSON::Field(emit_null: false)]
    property headers : Headers
    @[JSON::Field(emit_null: false)]
    property connect_timing : ConnectTiming
    @[JSON::Field(emit_null: false)]
    property device_bound_session_usages : Array(DeviceBoundSessionWithUsage)?
    @[JSON::Field(emit_null: false)]
    property client_security_state : ClientSecurityState?
    @[JSON::Field(emit_null: false)]
    property site_has_cookie_in_other_partition : Bool?
    @[JSON::Field(emit_null: false)]
    property applied_network_conditions_id : String?

    def initialize(@request_id : RequestId, @associated_cookies : Array(AssociatedCookie), @headers : Headers, @connect_timing : ConnectTiming, @device_bound_session_usages : Array(DeviceBoundSessionWithUsage)?, @client_security_state : ClientSecurityState?, @site_has_cookie_in_other_partition : Bool?, @applied_network_conditions_id : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.requestWillBeSentExtraInfo"
    end
  end

  @[Experimental]
  struct ResponseReceivedExtraInfoEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property blocked_cookies : Array(BlockedSetCookieWithReason)
    @[JSON::Field(emit_null: false)]
    property headers : Headers
    @[JSON::Field(emit_null: false)]
    property resource_ip_address_space : IPAddressSpace
    @[JSON::Field(emit_null: false)]
    property status_code : Int64
    @[JSON::Field(emit_null: false)]
    property headers_text : String?
    @[JSON::Field(emit_null: false)]
    property cookie_partition_key : CookiePartitionKey?
    @[JSON::Field(emit_null: false)]
    property cookie_partition_key_opaque : Bool?
    @[JSON::Field(emit_null: false)]
    property exempted_cookies : Array(ExemptedSetCookieWithReason)?

    def initialize(@request_id : RequestId, @blocked_cookies : Array(BlockedSetCookieWithReason), @headers : Headers, @resource_ip_address_space : IPAddressSpace, @status_code : Int64, @headers_text : String?, @cookie_partition_key : CookiePartitionKey?, @cookie_partition_key_opaque : Bool?, @exempted_cookies : Array(ExemptedSetCookieWithReason)?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.responseReceivedExtraInfo"
    end
  end

  @[Experimental]
  struct ResponseReceivedEarlyHintsEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property headers : Headers

    def initialize(@request_id : RequestId, @headers : Headers)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.responseReceivedEarlyHints"
    end
  end

  @[Experimental]
  struct TrustTokenOperationDoneEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property status : TrustTokenOperationDoneStatus
    @[JSON::Field(emit_null: false)]
    property type : TrustTokenOperationType
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property top_level_origin : String?
    @[JSON::Field(emit_null: false)]
    property issuer_origin : String?
    @[JSON::Field(emit_null: false)]
    property issued_token_count : Int64?

    def initialize(@status : TrustTokenOperationDoneStatus, @type : TrustTokenOperationType, @request_id : RequestId, @top_level_origin : String?, @issuer_origin : String?, @issued_token_count : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.trustTokenOperationDone"
    end
  end

  @[Experimental]
  struct PolicyUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize()
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.policyUpdated"
    end
  end

  @[Experimental]
  struct ReportingApiReportAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property report : ReportingApiReport

    def initialize(@report : ReportingApiReport)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.reportingApiReportAdded"
    end
  end

  @[Experimental]
  struct ReportingApiReportUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property report : ReportingApiReport

    def initialize(@report : ReportingApiReport)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.reportingApiReportUpdated"
    end
  end

  @[Experimental]
  struct ReportingApiEndpointsChangedForOriginEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property endpoints : Array(ReportingApiEndpoint)

    def initialize(@origin : String, @endpoints : Array(ReportingApiEndpoint))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.reportingApiEndpointsChangedForOrigin"
    end
  end

  @[Experimental]
  struct DeviceBoundSessionsAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property sessions : Array(DeviceBoundSession)

    def initialize(@sessions : Array(DeviceBoundSession))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.deviceBoundSessionsAdded"
    end
  end

  @[Experimental]
  struct DeviceBoundSessionEventOccurredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property event_id : DeviceBoundSessionEventId
    @[JSON::Field(emit_null: false)]
    property site : String
    @[JSON::Field(emit_null: false)]
    property succeeded : Bool
    @[JSON::Field(emit_null: false)]
    property session_id : String?
    @[JSON::Field(emit_null: false)]
    property creation_event_details : CreationEventDetails?
    @[JSON::Field(emit_null: false)]
    property refresh_event_details : RefreshEventDetails?
    @[JSON::Field(emit_null: false)]
    property termination_event_details : TerminationEventDetails?
    @[JSON::Field(emit_null: false)]
    property challenge_event_details : ChallengeEventDetails?

    def initialize(@event_id : DeviceBoundSessionEventId, @site : String, @succeeded : Bool, @session_id : String?, @creation_event_details : CreationEventDetails?, @refresh_event_details : RefreshEventDetails?, @termination_event_details : TerminationEventDetails?, @challenge_event_details : ChallengeEventDetails?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.deviceBoundSessionEventOccurred"
    end
  end

end
