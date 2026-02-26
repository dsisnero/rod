require "../cdp"
require "json"
require "time"

require "../runtime/runtime"

require "./types"

# Input/Output operations for streams produced by DevTools.
module Cdp::IO
  struct ReadResult
    include JSON::Serializable
    @[JSON::Field(key: "base64Encoded", emit_null: false)]
    property? base64_encoded : Bool?
    @[JSON::Field(key: "data", emit_null: false)]
    property data : String
    @[JSON::Field(key: "eof", emit_null: false)]
    property? eof : Bool

    def initialize(@base64_encoded : Bool?, @data : String, @eof : Bool)
    end
  end

  struct ResolveBlobResult
    include JSON::Serializable
    @[JSON::Field(key: "uuid", emit_null: false)]
    property uuid : String

    def initialize(@uuid : String)
    end
  end

  # Commands
  struct Close
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "handle", emit_null: false)]
    property handle : StreamHandle

    def initialize(@handle : StreamHandle)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IO.close"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Read
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "handle", emit_null: false)]
    property handle : StreamHandle
    @[JSON::Field(key: "offset", emit_null: false)]
    property offset : Int64?
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Int64?

    def initialize(@handle : StreamHandle, @offset : Int64?, @size : Int64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IO.read"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ReadResult
      res = ReadResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ResolveBlob
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IO.resolveBlob"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ResolveBlobResult
      res = ResolveBlobResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
