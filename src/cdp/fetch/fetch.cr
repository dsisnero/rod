require "../cdp"
require "json"
require "time"

require "../network/network"
require "../io/io"
require "../page/page"

require "./types"
require "./events"

# A domain for letting clients substitute browser's network layer with client code.
module Cdp::Fetch
  struct GetResponseBodyResult
    include JSON::Serializable
    @[JSON::Field(key: "body", emit_null: false)]
    property body : String
    @[JSON::Field(key: "base64Encoded", emit_null: false)]
    property? base64_encoded : Bool

    def initialize(@body : String, @base64_encoded : Bool)
    end
  end

  struct TakeResponseBodyAsStreamResult
    include JSON::Serializable
    @[JSON::Field(key: "stream", emit_null: false)]
    property stream : Cdp::IO::StreamHandle

    def initialize(@stream : Cdp::IO::StreamHandle)
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
    @[JSON::Field(key: "patterns", emit_null: false)]
    property patterns : Array(RequestPattern)?
    @[JSON::Field(key: "handleAuthRequests", emit_null: false)]
    property? handle_auth_requests : Bool?

    def initialize(@patterns : Array(RequestPattern)?, @handle_auth_requests : Bool?)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(key: "errorReason", emit_null: false)]
    property error_reason : Cdp::Network::ErrorReason

    def initialize(@request_id : RequestId, @error_reason : Cdp::Network::ErrorReason)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(key: "responseCode", emit_null: false)]
    property response_code : Int64
    @[JSON::Field(key: "responseHeaders", emit_null: false)]
    property response_headers : Array(HeaderEntry)?
    @[JSON::Field(key: "binaryResponseHeaders", emit_null: false)]
    property binary_response_headers : String?
    @[JSON::Field(key: "body", emit_null: false)]
    property body : String?
    @[JSON::Field(key: "responsePhrase", emit_null: false)]
    property response_phrase : String?

    def initialize(@request_id : RequestId, @response_code : Int64, @response_headers : Array(HeaderEntry)?, @binary_response_headers : String?, @body : String?, @response_phrase : String?)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String?
    @[JSON::Field(key: "method", emit_null: false)]
    property method : String?
    @[JSON::Field(key: "postData", emit_null: false)]
    property post_data : String?
    @[JSON::Field(key: "headers", emit_null: false)]
    property headers : Array(HeaderEntry)?
    @[JSON::Field(key: "interceptResponse", emit_null: false)]
    property? intercept_response : Bool?

    def initialize(@request_id : RequestId, @url : String?, @method : String?, @post_data : String?, @headers : Array(HeaderEntry)?, @intercept_response : Bool?)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(key: "authChallengeResponse", emit_null: false)]
    property auth_challenge_response : AuthChallengeResponse

    def initialize(@request_id : RequestId, @auth_challenge_response : AuthChallengeResponse)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(key: "responseCode", emit_null: false)]
    property response_code : Int64?
    @[JSON::Field(key: "responsePhrase", emit_null: false)]
    property response_phrase : String?
    @[JSON::Field(key: "responseHeaders", emit_null: false)]
    property response_headers : Array(HeaderEntry)?
    @[JSON::Field(key: "binaryResponseHeaders", emit_null: false)]
    property binary_response_headers : String?

    def initialize(@request_id : RequestId, @response_code : Int64?, @response_phrase : String?, @response_headers : Array(HeaderEntry)?, @binary_response_headers : String?)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId

    def initialize(@request_id : RequestId)
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
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : RequestId

    def initialize(@request_id : RequestId)
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
