require "json"
require "../cdp"
require "./types"

# Defines events for background web platform features.
@[Experimental]
module Cdp::BackgroundService
  # Commands
  struct StartObserving
    include JSON::Serializable
    include Cdp::Request

    property service : ServiceName

    def initialize(@service : ServiceName)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BackgroundService.startObserving"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopObserving
    include JSON::Serializable
    include Cdp::Request

    property service : ServiceName

    def initialize(@service : ServiceName)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BackgroundService.stopObserving"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetRecording
    include JSON::Serializable
    include Cdp::Request

    property should_record : Bool
    property service : ServiceName

    def initialize(@should_record : Bool, @service : ServiceName)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BackgroundService.setRecording"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearEvents
    include JSON::Serializable
    include Cdp::Request

    property service : ServiceName

    def initialize(@service : ServiceName)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BackgroundService.clearEvents"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
