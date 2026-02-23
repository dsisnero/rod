require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Query and modify DOM storage.
@[Experimental]
module Cdp::DOMStorage
  struct GetDOMStorageItemsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property entries : Array(Cdp::NodeType)

    def initialize(@entries : Array(Cdp::NodeType))
    end
  end

  # Commands
  struct Clear
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType

    def initialize(@storage_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMStorage.clear"
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
      "DOMStorage.disable"
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
      "DOMStorage.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetDOMStorageItems
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType

    def initialize(@storage_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMStorage.getDOMStorageItems"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDOMStorageItemsResult
      res = GetDOMStorageItemsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RemoveDOMStorageItem
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key : String

    def initialize(@storage_id : Cdp::NodeType, @key : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMStorage.removeDOMStorageItem"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDOMStorageItem
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : String

    def initialize(@storage_id : Cdp::NodeType, @key : String, @value : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMStorage.setDOMStorageItem"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
