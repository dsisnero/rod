require "../cdp"
require "json"
require "time"

# This domain provides commands to trigger the "Find in page" feature.
@[Experimental]
module Cdp::FindInPage
  # Commands
  struct FindFirst
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "query", emit_null: false)]
    property query : String

    def initialize(@query : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FindInPage.findFirst"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct FindNext
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FindInPage.findNext"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct FindPrev
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FindInPage.findPrev"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Stop
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FindInPage.stop"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
