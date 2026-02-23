require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Audits domain allows investigation of page violations and possible improvements.
@[Experimental]
module Cdp::Audits
  struct GetEncodedResponseResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property body : String?
    @[JSON::Field(emit_null: false)]
    property original_size : Int64
    @[JSON::Field(emit_null: false)]
    property encoded_size : Int64

    def initialize(@body : String?, @original_size : Int64, @encoded_size : Int64)
    end
  end

  struct CheckFormsIssuesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property form_issues : Array(Cdp::NodeType)

    def initialize(@form_issues : Array(Cdp::NodeType))
    end
  end

  # Commands
  struct GetEncodedResponse
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property encoding : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property quality : Float64?
    @[JSON::Field(emit_null: false)]
    property? size_only : Bool?

    def initialize(@request_id : Cdp::NodeType, @encoding : Cdp::NodeType, @quality : Float64?, @size_only : Bool?)
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
    @[JSON::Field(emit_null: false)]
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
