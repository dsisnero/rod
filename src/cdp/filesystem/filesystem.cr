require "json"
require "../cdp"
require "./types"

@[Experimental]
module Cdp::FileSystem
  # Commands
  struct GetDirectory
    include JSON::Serializable
    include Cdp::Request

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

  struct GetDirectoryResult
    include JSON::Serializable

    property directory : Directory

    def initialize(@directory : Directory)
    end
  end
end
