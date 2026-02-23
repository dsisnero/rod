
require "../cdp"
require "json"
require "time"


require "./types"
require "./events"

#
@[Experimental]
module Cdp::SmartCardEmulation

  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportEstablishContextResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property context_id : Int64

    def initialize(@request_id : String, @context_id : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportEstablishContextResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportReleaseContextResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String

    def initialize(@request_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportReleaseContextResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportListReadersResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property readers : Array(String)

    def initialize(@request_id : String, @readers : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportListReadersResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportGetStatusChangeResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property reader_states : Array(ReaderStateOut)

    def initialize(@request_id : String, @reader_states : Array(ReaderStateOut))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportGetStatusChangeResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportBeginTransactionResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64

    def initialize(@request_id : String, @handle : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportBeginTransactionResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportPlainResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String

    def initialize(@request_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportPlainResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportConnectResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property handle : Int64
    @[JSON::Field(emit_null: false)]
    property active_protocol : Protocol?

    def initialize(@request_id : String, @handle : Int64, @active_protocol : Protocol?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportConnectResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportDataResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@request_id : String, @data : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportDataResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportStatusResult
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property reader_name : String
    @[JSON::Field(emit_null: false)]
    property state : ConnectionState
    @[JSON::Field(emit_null: false)]
    property atr : String
    @[JSON::Field(emit_null: false)]
    property protocol : Protocol?

    def initialize(@request_id : String, @reader_name : String, @state : ConnectionState, @atr : String, @protocol : Protocol?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportStatusResult"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReportError
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : String
    @[JSON::Field(emit_null: false)]
    property result_code : ResultCode

    def initialize(@request_id : String, @result_code : ResultCode)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SmartCardEmulation.reportError"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

end
