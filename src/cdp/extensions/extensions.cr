require "json"
require "../cdp"
require "./types"

# Defines commands and events for browser extensions.
@[Experimental]
module Cdp::Extensions
  # Commands
  struct TriggerAction
    include JSON::Serializable
    include Cdp::Request

    property id : String
    property target_id : String

    def initialize(@id : String, @target_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.triggerAction"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct LoadUnpacked
    include JSON::Serializable
    include Cdp::Request

    property path : String
    @[JSON::Field(emit_null: false)]
    property enable_in_incognito : Bool?

    def initialize(@path : String, @enable_in_incognito : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.loadUnpacked"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : LoadUnpackedResult
      res = LoadUnpackedResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct LoadUnpackedResult
    include JSON::Serializable

    property id : String

    def initialize(@id : String)
    end
  end

  struct Uninstall
    include JSON::Serializable
    include Cdp::Request

    property id : String

    def initialize(@id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.uninstall"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetStorageItems
    include JSON::Serializable
    include Cdp::Request

    property id : String
    property storage_area : StorageArea
    @[JSON::Field(emit_null: false)]
    property keys : Array(String)?

    def initialize(@id : String, @storage_area : StorageArea, @keys : Array(String)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.getStorageItems"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetStorageItemsResult
      res = GetStorageItemsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetStorageItemsResult
    include JSON::Serializable

    property data : JSON::Any

    def initialize(@data : JSON::Any)
    end
  end

  struct RemoveStorageItems
    include JSON::Serializable
    include Cdp::Request

    property id : String
    property storage_area : StorageArea
    property keys : Array(String)

    def initialize(@id : String, @storage_area : StorageArea, @keys : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.removeStorageItems"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearStorageItems
    include JSON::Serializable
    include Cdp::Request

    property id : String
    property storage_area : StorageArea

    def initialize(@id : String, @storage_area : StorageArea)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.clearStorageItems"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetStorageItems
    include JSON::Serializable
    include Cdp::Request

    property id : String
    property storage_area : StorageArea
    property values : JSON::Any

    def initialize(@id : String, @storage_area : StorageArea, @values : JSON::Any)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Extensions.setStorageItems"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
