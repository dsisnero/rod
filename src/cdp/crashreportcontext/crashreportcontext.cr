require "../cdp"
require "json"
require "time"

require "../page/page"

require "./types"

# This domain exposes the current state of the CrashReportContext API.
@[Experimental]
module Cdp::CrashReportContext
  struct GetEntriesResult
    include JSON::Serializable
    @[JSON::Field(key: "entries", emit_null: false)]
    property entries : Array(CrashReportContextEntry)

    def initialize(@entries : Array(CrashReportContextEntry))
    end
  end

  # Commands
  struct GetEntries
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CrashReportContext.getEntries"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetEntriesResult
      Cdp.call(proto_req, self, GetEntriesResult, c)
    end
  end
end
