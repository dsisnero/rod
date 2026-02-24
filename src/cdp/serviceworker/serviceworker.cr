require "../cdp"
require "json"
require "time"

require "../target/target"

require "./types"
require "./events"

#
@[Experimental]
module Cdp::ServiceWorker
  # Commands
  struct DeliverPushMessage
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@origin : String, @registration_id : RegistrationID, @data : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.deliverPushMessage"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DispatchSyncEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(emit_null: false)]
    property tag : String
    @[JSON::Field(emit_null: false)]
    property? last_chance : Bool

    def initialize(@origin : String, @registration_id : RegistrationID, @tag : String, @last_chance : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.dispatchSyncEvent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DispatchPeriodicSyncEvent
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(emit_null: false)]
    property tag : String

    def initialize(@origin : String, @registration_id : RegistrationID, @tag : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.dispatchPeriodicSyncEvent"
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
      "ServiceWorker.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetForceUpdateOnPageLoad
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? force_update_on_page_load : Bool

    def initialize(@force_update_on_page_load : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.setForceUpdateOnPageLoad"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SkipWaiting
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property scope_url : String

    def initialize(@scope_url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.skipWaiting"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StartWorker
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property scope_url : String

    def initialize(@scope_url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.startWorker"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopAllWorkers
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.stopAllWorkers"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopWorker
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property version_id : String

    def initialize(@version_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.stopWorker"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Unregister
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property scope_url : String

    def initialize(@scope_url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.unregister"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct UpdateRegistration
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property scope_url : String

    def initialize(@scope_url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "ServiceWorker.updateRegistration"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
