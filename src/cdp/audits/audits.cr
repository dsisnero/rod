require "../cdp"
require "json"
require "time"

require "../network/network"
require "../page/page"
require "../runtime/runtime"
require "../dom/dom"

require "./types"
require "./events"

# Audits domain allows investigation of page violations and possible improvements.
@[Experimental]
module Cdp::Audits
  struct GetEncodedResponseResult
    include JSON::Serializable
    @[JSON::Field(key: "body", emit_null: false)]
    property body : String?
    @[JSON::Field(key: "originalSize", emit_null: false)]
    property original_size : Int64
    @[JSON::Field(key: "encodedSize", emit_null: false)]
    property encoded_size : Int64

    def initialize(@body : String?, @original_size : Int64, @encoded_size : Int64)
    end
  end

  struct CheckFormsIssuesResult
    include JSON::Serializable
    @[JSON::Field(key: "formIssues", emit_null: false)]
    property form_issues : Array(GenericIssueDetails)

    def initialize(@form_issues : Array(GenericIssueDetails))
    end
  end

  # Commands
  struct GetEncodedResponse
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : Cdp::Network::RequestId
    @[JSON::Field(key: "encoding", emit_null: false)]
    property encoding : GetEncodedResponseEncoding
    @[JSON::Field(key: "quality", emit_null: false)]
    property quality : Float64?
    @[JSON::Field(key: "sizeOnly", emit_null: false)]
    property? size_only : Bool?

    def initialize(@request_id : Cdp::Network::RequestId, @encoding : GetEncodedResponseEncoding, @quality : Float64?, @size_only : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Audits.getEncodedResponse"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetEncodedResponseResult
      res = GetEncodedResponseResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Audits.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Audits.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CheckContrast
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "reportAaa", emit_null: false)]
    property? report_aaa : Bool?

    def initialize(@report_aaa : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Audits.checkContrast"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CheckFormsIssues
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Audits.checkFormsIssues"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CheckFormsIssuesResult
      res = CheckFormsIssuesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
