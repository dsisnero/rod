
require "../cdp"
require "json"
require "time"

require "../network/network"
require "../storage/storage"

require "./types"

#
@[Experimental]
module Cdp::FileSystem
  struct GetDirectoryResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property directory : Directory

    def initialize(@directory : Directory)
    end
  end


  # Commands
  struct GetDirectory
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property bucket_file_system_locator : BucketFileSystemLocator

    def initialize(@bucket_file_system_locator : BucketFileSystemLocator)
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
