require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Network
  struct DataReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property data_length : Int64
    @[JSON::Field(emit_null: false)]
    property encoded_data_length : Int64
    @[JSON::Field(emit_null: false)]
    property data : String?

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @data_length : Int64, @encoded_data_length : Int64, @data : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.dataReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.dataReceived"
    end
  end

  struct EventSourceMessageReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property event_name : String
    @[JSON::Field(emit_null: false)]
    property event_id : String
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @event_name : String, @event_id : String, @data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.eventSourceMessageReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.eventSourceMessageReceived"
    end
  end

  struct LoadingFailedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property error_text : String
    @[JSON::Field(emit_null: false)]
    property? canceled : Bool?
    @[JSON::Field(emit_null: false)]
    property blocked_reason : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cors_error_status : Cdp::NodeType?

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @type : Cdp::NodeType, @error_text : String, @canceled : Bool?, @blocked_reason : Cdp::NodeType?, @cors_error_status : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.loadingFailed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.loadingFailed"
    end
  end

  struct LoadingFinishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property encoded_data_length : Float64

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @encoded_data_length : Float64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.loadingFinished"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.loadingFinished"
    end
  end

  struct RequestServedFromCacheEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.requestServedFromCache"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.requestServedFromCache"
    end
  end

  struct RequestWillBeSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property document_url : String
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property wall_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property initiator : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? redirect_has_extra_info : Bool
    @[JSON::Field(emit_null: false)]
    property redirect_response : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? has_user_gesture : Bool?
    @[JSON::Field(emit_null: false)]
    property render_blocking_behavior : Cdp::NodeType?

    def initialize(@request_id : Cdp::NodeType, @loader_id : Cdp::NodeType, @document_url : String, @request : Cdp::NodeType, @timestamp : Cdp::NodeType, @wall_time : Cdp::NodeType, @initiator : Cdp::NodeType, @redirect_has_extra_info : Bool, @redirect_response : Cdp::NodeType?, @type : Cdp::NodeType?, @frame_id : Cdp::NodeType?, @has_user_gesture : Bool?, @render_blocking_behavior : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.requestWillBeSent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.requestWillBeSent"
    end
  end

  @[Experimental]
  struct ResourceChangedPriorityEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property new_priority : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @new_priority : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.resourceChangedPriority"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.resourceChangedPriority"
    end
  end

  @[Experimental]
  struct SignedExchangeReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property info : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @info : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.signedExchangeReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.signedExchangeReceived"
    end
  end

  struct ResponseReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? has_extra_info : Bool
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?

    def initialize(@request_id : Cdp::NodeType, @loader_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @type : Cdp::NodeType, @response : Cdp::NodeType, @has_extra_info : Bool, @frame_id : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.responseReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.responseReceived"
    end
  end

  struct WebSocketClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketClosed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketClosed"
    end
  end

  struct WebSocketCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property initiator : Cdp::NodeType?

    def initialize(@request_id : Cdp::NodeType, @url : String, @initiator : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketCreated"
    end
  end

  struct WebSocketFrameErrorEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property error_message : String

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @error_message : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketFrameError"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketFrameError"
    end
  end

  struct WebSocketFrameReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @response : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketFrameReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketFrameReceived"
    end
  end

  struct WebSocketFrameSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @response : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketFrameSent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketFrameSent"
    end
  end

  struct WebSocketHandshakeResponseReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @response : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketHandshakeResponseReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketHandshakeResponseReceived"
    end
  end

  struct WebSocketWillSendHandshakeRequestEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property wall_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @wall_time : Cdp::NodeType, @request : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webSocketWillSendHandshakeRequest"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webSocketWillSendHandshakeRequest"
    end
  end

  struct WebTransportCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property transport_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property initiator : Cdp::NodeType?

    def initialize(@transport_id : Cdp::NodeType, @url : String, @timestamp : Cdp::NodeType, @initiator : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webTransportCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webTransportCreated"
    end
  end

  struct WebTransportConnectionEstablishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property transport_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@transport_id : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webTransportConnectionEstablished"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webTransportConnectionEstablished"
    end
  end

  struct WebTransportClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property transport_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@transport_id : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.webTransportClosed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.webTransportClosed"
    end
  end

  @[Experimental]
  struct DirectTCPSocketCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property remote_addr : String
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64
    @[JSON::Field(emit_null: false)]
    property options : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property initiator : Cdp::NodeType?

    def initialize(@identifier : Cdp::NodeType, @remote_addr : String, @remote_port : Int64, @options : Cdp::NodeType, @timestamp : Cdp::NodeType, @initiator : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directTCPSocketCreated"
    end
  end

  @[Experimental]
  struct DirectTCPSocketOpenedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property remote_addr : String
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property local_addr : String?
    @[JSON::Field(emit_null: false)]
    property local_port : Int64?

    def initialize(@identifier : Cdp::NodeType, @remote_addr : String, @remote_port : Int64, @timestamp : Cdp::NodeType, @local_addr : String?, @local_port : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketOpened"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directTCPSocketOpened"
    end
  end

  @[Experimental]
  struct DirectTCPSocketAbortedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property error_message : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @error_message : String, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketAborted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directTCPSocketAborted"
    end
  end

  @[Experimental]
  struct DirectTCPSocketClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketClosed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directTCPSocketClosed"
    end
  end

  @[Experimental]
  struct DirectTCPSocketChunkSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @data : String, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketChunkSent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directTCPSocketChunkSent"
    end
  end

  @[Experimental]
  struct DirectTCPSocketChunkReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @data : String, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directTCPSocketChunkReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directTCPSocketChunkReceived"
    end
  end

  @[Experimental]
  struct DirectUDPSocketJoinedMulticastGroupEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property ip_address : String

    def initialize(@identifier : Cdp::NodeType, @ip_address : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketJoinedMulticastGroup"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketJoinedMulticastGroup"
    end
  end

  @[Experimental]
  struct DirectUDPSocketLeftMulticastGroupEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property ip_address : String

    def initialize(@identifier : Cdp::NodeType, @ip_address : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketLeftMulticastGroup"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketLeftMulticastGroup"
    end
  end

  @[Experimental]
  struct DirectUDPSocketCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property options : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property initiator : Cdp::NodeType?

    def initialize(@identifier : Cdp::NodeType, @options : Cdp::NodeType, @timestamp : Cdp::NodeType, @initiator : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketCreated"
    end
  end

  @[Experimental]
  struct DirectUDPSocketOpenedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property local_addr : String
    @[JSON::Field(emit_null: false)]
    property local_port : Int64
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property remote_addr : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?

    def initialize(@identifier : Cdp::NodeType, @local_addr : String, @local_port : Int64, @timestamp : Cdp::NodeType, @remote_addr : String?, @remote_port : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketOpened"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketOpened"
    end
  end

  @[Experimental]
  struct DirectUDPSocketAbortedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property error_message : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @error_message : String, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketAborted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketAborted"
    end
  end

  @[Experimental]
  struct DirectUDPSocketClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketClosed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketClosed"
    end
  end

  @[Experimental]
  struct DirectUDPSocketChunkSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property message : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @message : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketChunkSent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketChunkSent"
    end
  end

  @[Experimental]
  struct DirectUDPSocketChunkReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property message : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType, @message : Cdp::NodeType, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.directUDPSocketChunkReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.directUDPSocketChunkReceived"
    end
  end

  @[Experimental]
  struct RequestWillBeSentExtraInfoEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property associated_cookies : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property connect_timing : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property device_bound_session_usages : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property client_security_state : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? site_has_cookie_in_other_partition : Bool?
    @[JSON::Field(emit_null: false)]
    property applied_network_conditions_id : String?

    def initialize(@request_id : Cdp::NodeType, @associated_cookies : Array(Cdp::NodeType), @headers : Cdp::NodeType, @connect_timing : Cdp::NodeType, @device_bound_session_usages : Array(Cdp::NodeType)?, @client_security_state : Cdp::NodeType?, @site_has_cookie_in_other_partition : Bool?, @applied_network_conditions_id : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.requestWillBeSentExtraInfo"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.requestWillBeSentExtraInfo"
    end
  end

  @[Experimental]
  struct ResponseReceivedExtraInfoEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property blocked_cookies : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property resource_ip_address_space : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property status_code : Int64
    @[JSON::Field(emit_null: false)]
    property headers_text : String?
    @[JSON::Field(emit_null: false)]
    property cookie_partition_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? cookie_partition_key_opaque : Bool?
    @[JSON::Field(emit_null: false)]
    property exempted_cookies : Array(Cdp::NodeType)?

    def initialize(@request_id : Cdp::NodeType, @blocked_cookies : Array(Cdp::NodeType), @headers : Cdp::NodeType, @resource_ip_address_space : Cdp::NodeType, @status_code : Int64, @headers_text : String?, @cookie_partition_key : Cdp::NodeType?, @cookie_partition_key_opaque : Bool?, @exempted_cookies : Array(Cdp::NodeType)?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.responseReceivedExtraInfo"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.responseReceivedExtraInfo"
    end
  end

  @[Experimental]
  struct ResponseReceivedEarlyHintsEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @headers : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.responseReceivedEarlyHints"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.responseReceivedEarlyHints"
    end
  end

  @[Experimental]
  struct TrustTokenOperationDoneEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property top_level_origin : String?
    @[JSON::Field(emit_null: false)]
    property issuer_origin : String?
    @[JSON::Field(emit_null: false)]
    property issued_token_count : Int64?

    def initialize(@status : Cdp::NodeType, @type : Cdp::NodeType, @request_id : Cdp::NodeType, @top_level_origin : String?, @issuer_origin : String?, @issued_token_count : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.trustTokenOperationDone"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.trustTokenOperationDone"
    end
  end

  @[Experimental]
  struct PolicyUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.policyUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.policyUpdated"
    end
  end

  @[Experimental]
  struct ReportingApiReportAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property report : Cdp::NodeType

    def initialize(@report : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.reportingApiReportAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.reportingApiReportAdded"
    end
  end

  @[Experimental]
  struct ReportingApiReportUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property report : Cdp::NodeType

    def initialize(@report : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.reportingApiReportUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
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
    property endpoints : Array(Cdp::NodeType)

    def initialize(@origin : String, @endpoints : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.reportingApiEndpointsChangedForOrigin"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.reportingApiEndpointsChangedForOrigin"
    end
  end

  @[Experimental]
  struct DeviceBoundSessionsAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property sessions : Array(Cdp::NodeType)

    def initialize(@sessions : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.deviceBoundSessionsAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.deviceBoundSessionsAdded"
    end
  end

  @[Experimental]
  struct DeviceBoundSessionEventOccurredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property event_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property site : String
    @[JSON::Field(emit_null: false)]
    property? succeeded : Bool
    @[JSON::Field(emit_null: false)]
    property session_id : String?
    @[JSON::Field(emit_null: false)]
    property creation_event_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property refresh_event_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property termination_event_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property challenge_event_details : Cdp::NodeType?

    def initialize(@event_id : Cdp::NodeType, @site : String, @succeeded : Bool, @session_id : String?, @creation_event_details : Cdp::NodeType?, @refresh_event_details : Cdp::NodeType?, @termination_event_details : Cdp::NodeType?, @challenge_event_details : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Network.deviceBoundSessionEventOccurred"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Network.deviceBoundSessionEventOccurred"
    end
  end
end
