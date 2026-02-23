require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"

#
@[Experimental]
module Cdp::FileSystem
  struct GetDirectoryResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property directory : Cdp::NodeType

    def initialize(@directory : Cdp::NodeType)
    end
  end

  # Commands
  struct GetDirectory
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property bucket_file_system_locator : Cdp::NodeType

    def initialize(@bucket_file_system_locator : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FileSystem.getDirectory"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDirectoryResult
      res = GetDirectoryResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
