
require "../cdp"
require "json"
require "time"


module Cdp::SmartCardEmulation
  struct EstablishContextRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String

    def initialize(@request_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.establishContextRequested"
    end
  end

  struct ReleaseContextRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property context_id : Int64

    def initialize(@request_id : String, @context_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.releaseContextRequested"
    end
  end

  struct ListReadersRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property context_id : Int64

    def initialize(@request_id : String, @context_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.listReadersRequested"
    end
  end

  struct GetStatusChangeRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property context_id : Int64
    @[JSON::Field(emit_null: false)]
    property reader_states : Array(ReaderStateIn)
    @[JSON::Field(emit_null: false)]
    property timeout : Int64?

    def initialize(@request_id : String, @context_id : Int64, @reader_states : Array(ReaderStateIn), @timeout : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.getStatusChangeRequested"
    end
  end

  struct CancelRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property context_id : Int64

    def initialize(@request_id : String, @context_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.cancelRequested"
    end
  end

  struct ConnectRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property context_id : Int64
    @[JSON::Field(emit_null: false)]
    property reader : String
    @[JSON::Field(emit_null: false)]
    property share_mode : ShareMode
    @[JSON::Field(emit_null: false)]
    property preferred_protocols : ProtocolSet

    def initialize(@request_id : String, @context_id : Int64, @reader : String, @share_mode : ShareMode, @preferred_protocols : ProtocolSet)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.connectRequested"
    end
  end

  struct DisconnectRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property disposition : Disposition

    def initialize(@request_id : String, @handle : Int64, @disposition : Disposition)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.disconnectRequested"
    end
  end

  struct TransmitRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property protocol : Protocol?

    def initialize(@request_id : String, @handle : Int64, @data : String, @protocol : Protocol?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.transmitRequested"
    end
  end

  struct ControlRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property control_code : Int64
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@request_id : String, @handle : Int64, @control_code : Int64, @data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.controlRequested"
    end
  end

  struct GetAttribRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property attrib_id : Int64

    def initialize(@request_id : String, @handle : Int64, @attrib_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.getAttribRequested"
    end
  end

  struct SetAttribRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property attrib_id : Int64
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@request_id : String, @handle : Int64, @attrib_id : Int64, @data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.setAttribRequested"
    end
  end

  struct StatusRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64

    def initialize(@request_id : String, @handle : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.statusRequested"
    end
  end

  struct BeginTransactionRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64

    def initialize(@request_id : String, @handle : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.beginTransactionRequested"
    end
  end

  struct EndTransactionRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property disposition : Disposition

    def initialize(@request_id : String, @handle : Int64, @disposition : Disposition)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "SmartCardEmulation.endTransactionRequested"
    end
  end

end
