
require "../cdp"
require "json"
require "time"

require "../page/page"
require "../runtime/runtime"

require "./types"
require "./events"

# This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
# that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
# the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
# nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
# and never sends the same node twice. It is client's responsibility to collect information about
# the nodes that were sent to the client. Note that `iframe` owner elements will return
# corresponding document elements as their child nodes.
module Cdp::DOM
  @[Experimental]
  struct CollectClassNamesFromSubtreeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property class_names : Array(String)

    def initialize(@class_names : Array(String))
    end
  end

  @[Experimental]
  struct CopyToResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct DescribeNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node : Node

    def initialize(@node : Node)
    end
  end

  struct GetAttributesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property attributes : Array(String)

    def initialize(@attributes : Array(String))
    end
  end

  struct GetBoxModelResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property model : BoxModel

    def initialize(@model : BoxModel)
    end
  end

  @[Experimental]
  struct GetContentQuadsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property quads : Array(Quad)

    def initialize(@quads : Array(Quad))
    end
  end

  struct GetDocumentResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property root : Node

    def initialize(@root : Node)
    end
  end

  @[Experimental]
  struct GetNodesForSubtreeByStyleResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  struct GetNodeForLocationResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?

    def initialize(@backend_node_id : BackendNodeId, @frame_id : Cdp::Page::FrameId, @node_id : NodeId?)
    end
  end

  struct GetOuterHTMLResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property outer_html : String

    def initialize(@outer_html : String)
    end
  end

  @[Experimental]
  struct GetRelayoutBoundaryResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct GetSearchResultsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  struct MoveToResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct PerformSearchResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property search_id : String
    @[JSON::Field(emit_null: false)]
    property result_count : Int64

    def initialize(@search_id : String, @result_count : Int64)
    end
  end

  @[Experimental]
  struct PushNodeByPathToFrontendResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct PushNodesByBackendIdsToFrontendResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  struct QuerySelectorResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct QuerySelectorAllResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  @[Experimental]
  struct GetTopLayerElementsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  @[Experimental]
  struct GetElementByRelationResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct RequestNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct ResolveNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property object : Cdp::Runtime::RemoteObject

    def initialize(@object : Cdp::Runtime::RemoteObject)
    end
  end

  @[Experimental]
  struct GetNodeStackTracesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property creation : Cdp::Runtime::StackTrace?

    def initialize(@creation : Cdp::Runtime::StackTrace?)
    end
  end

  @[Experimental]
  struct GetFileInfoResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property path : String

    def initialize(@path : String)
    end
  end

  @[Experimental]
  struct GetDetachedDomNodesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property detached_nodes : Array(DetachedElementInfo)

    def initialize(@detached_nodes : Array(DetachedElementInfo))
    end
  end

  struct SetNodeNameResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct GetFrameOwnerResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?

    def initialize(@backend_node_id : BackendNodeId, @node_id : NodeId?)
    end
  end

  @[Experimental]
  struct GetContainerForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?

    def initialize(@node_id : NodeId?)
    end
  end

  @[Experimental]
  struct GetQueryingDescendantsForContainerResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  @[Experimental]
  struct GetAnchorElementResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct ForceShowPopoverResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end


  # Commands
  @[Experimental]
  struct CollectClassNamesFromSubtree
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.collectClassNamesFromSubtree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CollectClassNamesFromSubtreeResult
      res = CollectClassNamesFromSubtreeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct CopyTo
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property target_node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property insert_before_node_id : NodeId?

    def initialize(@node_id : NodeId, @target_node_id : NodeId, @insert_before_node_id : NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.copyTo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CopyToResult
      res = CopyToResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct DescribeNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(emit_null: false)]
    property depth : Int64?
    @[JSON::Field(emit_null: false)]
    property pierce : Bool?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?, @depth : Int64?, @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.describeNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : DescribeNodeResult
      res = DescribeNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ScrollIntoViewIfNeeded
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(emit_null: false)]
    property rect : Rect?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?, @rect : Rect?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.scrollIntoViewIfNeeded"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct DiscardSearchResults
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property search_id : String

    def initialize(@search_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.discardSearchResults"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property include_whitespace : EnableIncludeWhitespace?

    def initialize(@include_whitespace : EnableIncludeWhitespace?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Focus
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.focus"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetAttributes
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getAttributes"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAttributesResult
      res = GetAttributesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetBoxModel
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getBoxModel"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBoxModelResult
      res = GetBoxModelResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetContentQuads
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getContentQuads"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetContentQuadsResult
      res = GetContentQuadsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetDocument
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property depth : Int64?
    @[JSON::Field(emit_null: false)]
    property pierce : Bool?

    def initialize(@depth : Int64?, @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getDocument"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDocumentResult
      res = GetDocumentResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetNodesForSubtreeByStyle
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property computed_styles : Array(CSSComputedStyleProperty)
    @[JSON::Field(emit_null: false)]
    property pierce : Bool?

    def initialize(@node_id : NodeId, @computed_styles : Array(CSSComputedStyleProperty), @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getNodesForSubtreeByStyle"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNodesForSubtreeByStyleResult
      res = GetNodesForSubtreeByStyleResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetNodeForLocation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property x : Int64
    @[JSON::Field(emit_null: false)]
    property y : Int64
    @[JSON::Field(emit_null: false)]
    property include_user_agent_shadow_dom : Bool?
    @[JSON::Field(emit_null: false)]
    property ignore_pointer_events_none : Bool?

    def initialize(@x : Int64, @y : Int64, @include_user_agent_shadow_dom : Bool?, @ignore_pointer_events_none : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getNodeForLocation"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNodeForLocationResult
      res = GetNodeForLocationResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetOuterHTML
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(emit_null: false)]
    property include_shadow_dom : Bool?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?, @include_shadow_dom : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getOuterHTML"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetOuterHTMLResult
      res = GetOuterHTMLResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetRelayoutBoundary
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getRelayoutBoundary"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetRelayoutBoundaryResult
      res = GetRelayoutBoundaryResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetSearchResults
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property search_id : String
    @[JSON::Field(emit_null: false)]
    property from_index : Int64
    @[JSON::Field(emit_null: false)]
    property to_index : Int64

    def initialize(@search_id : String, @from_index : Int64, @to_index : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getSearchResults"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSearchResultsResult
      res = GetSearchResultsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct MarkUndoableState
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.markUndoableState"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct MoveTo
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property target_node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property insert_before_node_id : NodeId?

    def initialize(@node_id : NodeId, @target_node_id : NodeId, @insert_before_node_id : NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.moveTo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : MoveToResult
      res = MoveToResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct PerformSearch
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property query : String
    @[JSON::Field(emit_null: false)]
    property include_user_agent_shadow_dom : Bool?

    def initialize(@query : String, @include_user_agent_shadow_dom : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.performSearch"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PerformSearchResult
      res = PerformSearchResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct PushNodeByPathToFrontend
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property path : String

    def initialize(@path : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.pushNodeByPathToFrontend"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PushNodeByPathToFrontendResult
      res = PushNodeByPathToFrontendResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct PushNodesByBackendIdsToFrontend
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property backend_node_ids : Array(BackendNodeId)

    def initialize(@backend_node_ids : Array(BackendNodeId))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.pushNodesByBackendIdsToFrontend"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PushNodesByBackendIdsToFrontendResult
      res = PushNodesByBackendIdsToFrontendResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct QuerySelector
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property selector : String

    def initialize(@node_id : NodeId, @selector : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.querySelector"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : QuerySelectorResult
      res = QuerySelectorResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct QuerySelectorAll
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property selector : String

    def initialize(@node_id : NodeId, @selector : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.querySelectorAll"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : QuerySelectorAllResult
      res = QuerySelectorAllResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetTopLayerElements
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getTopLayerElements"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetTopLayerElementsResult
      res = GetTopLayerElementsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetElementByRelation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property relation : GetElementByRelationRelation

    def initialize(@node_id : NodeId, @relation : GetElementByRelationRelation)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getElementByRelation"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetElementByRelationResult
      res = GetElementByRelationResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct Redo
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.redo"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveAttribute
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property name : String

    def initialize(@node_id : NodeId, @name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.removeAttribute"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.removeNode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RequestChildNodes
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property depth : Int64?
    @[JSON::Field(emit_null: false)]
    property pierce : Bool?

    def initialize(@node_id : NodeId, @depth : Int64?, @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.requestChildNodes"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RequestNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.requestNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestNodeResult
      res = RequestNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ResolveNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_group : String?
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::Runtime::ExecutionContextId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_group : String?, @execution_context_id : Cdp::Runtime::ExecutionContextId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.resolveNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ResolveNodeResult
      res = ResolveNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetAttributeValue
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String

    def initialize(@node_id : NodeId, @name : String, @value : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setAttributeValue"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetAttributesAsText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property name : String?

    def initialize(@node_id : NodeId, @text : String, @name : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setAttributesAsText"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetFileInputFiles
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property files : Array(String)
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@files : Array(String), @node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setFileInputFiles"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetNodeStackTracesEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setNodeStackTracesEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetNodeStackTraces
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getNodeStackTraces"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNodeStackTracesResult
      res = GetNodeStackTracesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetFileInfo
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getFileInfo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFileInfoResult
      res = GetFileInfoResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetDetachedDomNodes
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getDetachedDomNodes"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDetachedDomNodesResult
      res = GetDetachedDomNodesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetInspectedNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setInspectedNode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetNodeName
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property name : String

    def initialize(@node_id : NodeId, @name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setNodeName"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetNodeNameResult
      res = SetNodeNameResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetNodeValue
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property value : String

    def initialize(@node_id : NodeId, @value : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setNodeValue"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetOuterHTML
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property outer_html : String

    def initialize(@node_id : NodeId, @outer_html : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setOuterHTML"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct Undo
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.undo"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetFrameOwner
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId

    def initialize(@frame_id : Cdp::Page::FrameId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getFrameOwner"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFrameOwnerResult
      res = GetFrameOwnerResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetContainerForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property container_name : String?
    @[JSON::Field(emit_null: false)]
    property physical_axes : PhysicalAxes?
    @[JSON::Field(emit_null: false)]
    property logical_axes : LogicalAxes?
    @[JSON::Field(emit_null: false)]
    property queries_scroll_state : Bool?
    @[JSON::Field(emit_null: false)]
    property queries_anchored : Bool?

    def initialize(@node_id : NodeId, @container_name : String?, @physical_axes : PhysicalAxes?, @logical_axes : LogicalAxes?, @queries_scroll_state : Bool?, @queries_anchored : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getContainerForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetContainerForNodeResult
      res = GetContainerForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetQueryingDescendantsForContainer
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getQueryingDescendantsForContainer"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetQueryingDescendantsForContainerResult
      res = GetQueryingDescendantsForContainerResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAnchorElement
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property anchor_specifier : String?

    def initialize(@node_id : NodeId, @anchor_specifier : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getAnchorElement"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAnchorElementResult
      res = GetAnchorElementResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct ForceShowPopover
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property enable : Bool

    def initialize(@node_id : NodeId, @enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.forceShowPopover"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ForceShowPopoverResult
      res = ForceShowPopoverResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

end
