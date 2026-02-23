require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

#
@[Experimental]
module Cdp::Accessibility
  @[Experimental]
  struct GetPartialAXTreeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@nodes : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetFullAXTreeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@nodes : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetRootAXNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node : Cdp::NodeType

    def initialize(@node : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct GetAXNodeAndAncestorsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@nodes : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetChildAXNodesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@nodes : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct QueryAXTreeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@nodes : Array(Cdp::NodeType))
    end
  end

  # Commands
  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.disable"
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
      "Accessibility.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetPartialAXTree
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? fetch_relatives : Bool?

    def initialize(@node_id : Cdp::NodeType?, @backend_node_id : Cdp::NodeType?, @object_id : Cdp::NodeType?, @fetch_relatives : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.getPartialAXTree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPartialAXTreeResult
      res = GetPartialAXTreeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetFullAXTree
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property depth : Int64?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?

    def initialize(@depth : Int64?, @frame_id : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.getFullAXTree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFullAXTreeResult
      res = GetFullAXTreeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetRootAXNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?

    def initialize(@frame_id : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.getRootAXNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetRootAXNodeResult
      res = GetRootAXNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAXNodeAndAncestors
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::NodeType?

    def initialize(@node_id : Cdp::NodeType?, @backend_node_id : Cdp::NodeType?, @object_id : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.getAXNodeAndAncestors"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAXNodeAndAncestorsResult
      res = GetAXNodeAndAncestorsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetChildAXNodes
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?

    def initialize(@id : Cdp::NodeType, @frame_id : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.getChildAXNodes"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetChildAXNodesResult
      res = GetChildAXNodesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct QueryAXTree
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property accessible_name : String?
    @[JSON::Field(emit_null: false)]
    property role : String?

    def initialize(@node_id : Cdp::NodeType?, @backend_node_id : Cdp::NodeType?, @object_id : Cdp::NodeType?, @accessible_name : String?, @role : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Accessibility.queryAXTree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : QueryAXTreeResult
      res = QueryAXTreeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
