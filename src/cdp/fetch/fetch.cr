require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# A domain for letting clients substitute browser's network layer with client code.
module Cdp::Fetch
  struct GetResponseBodyResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property body : String
    @[JSON::Field(emit_null: false)]
    property? base64_encoded : Bool

    def initialize(@body : String, @base64_encoded : Bool)
    end
  end

  struct TakeResponseBodyAsStreamResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::NodeType

    def initialize(@stream : Cdp::NodeType)
    end
  end

  # Commands
  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.disable"
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
    property patterns : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property? handle_auth_requests : Bool?

    def initialize(@patterns : Array(Cdp::NodeType)?, @handle_auth_requests : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct FailRequest
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property error_reason : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @error_reason : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.failRequest"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct FulfillRequest
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response_code : Int64
    @[JSON::Field(emit_null: false)]
    property response_headers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property binary_response_headers : String?
    @[JSON::Field(emit_null: false)]
    property body : String?
    @[JSON::Field(emit_null: false)]
    property response_phrase : String?

    def initialize(@request_id : Cdp::NodeType, @response_code : Int64, @response_headers : Array(Cdp::NodeType)?, @binary_response_headers : String?, @body : String?, @response_phrase : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.fulfillRequest"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ContinueRequest
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property method : String?
    @[JSON::Field(emit_null: false)]
    property post_data : String?
    @[JSON::Field(emit_null: false)]
    property headers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property? intercept_response : Bool?

    def initialize(@request_id : Cdp::NodeType, @url : String?, @method : String?, @post_data : String?, @headers : Array(Cdp::NodeType)?, @intercept_response : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.continueRequest"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ContinueWithAuth
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property auth_challenge_response : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @auth_challenge_response : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.continueWithAuth"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ContinueResponse
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response_code : Int64?
    @[JSON::Field(emit_null: false)]
    property response_phrase : String?
    @[JSON::Field(emit_null: false)]
    property response_headers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property binary_response_headers : String?

    def initialize(@request_id : Cdp::NodeType, @response_code : Int64?, @response_phrase : String?, @response_headers : Array(Cdp::NodeType)?, @binary_response_headers : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.continueResponse"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
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
      "Fetch.getResponseBody"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetResponseBodyResult
      res = GetResponseBodyResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct TakeResponseBodyAsStream
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Fetch.takeResponseBodyAsStream"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : TakeResponseBodyAsStreamResult
      res = TakeResponseBodyAsStreamResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
