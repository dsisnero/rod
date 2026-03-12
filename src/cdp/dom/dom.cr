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
    @[JSON::Field(key: "classNames", emit_null: false)]
    property class_names : Array(String)

    def initialize(@class_names : Array(String))
    end
  end

  @[Experimental]
  struct CopyToResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct DescribeNodeResult
    include JSON::Serializable
    @[JSON::Field(key: "node", emit_null: false)]
    property node : Node

    def initialize(@node : Node)
    end
  end

  struct GetAttributesResult
    include JSON::Serializable
    @[JSON::Field(key: "attributes", emit_null: false)]
    property attributes : Array(String)

    def initialize(@attributes : Array(String))
    end
  end

  struct GetBoxModelResult
    include JSON::Serializable
    @[JSON::Field(key: "model", emit_null: false)]
    property model : BoxModel

    def initialize(@model : BoxModel)
    end
  end

  @[Experimental]
  struct GetContentQuadsResult
    include JSON::Serializable
    @[JSON::Field(key: "quads", emit_null: false)]
    property quads : Array(Quad)

    def initialize(@quads : Array(Quad))
    end

    # OnePointInside returns center point of the first quad with area >= 1.
    def one_point_inside : Point?
      @quads.each do |quad|
        if Cdp::DOM.area(quad) >= 1.0
          return Cdp::DOM.center(quad)
        end
      end
      nil
    end

    # Box returns smallest axis-aligned rect covering all quads.
    def box : Rect?
      return nil if @quads.empty?

      left = Float64::MAX
      top = Float64::MAX
      right = Float64::MIN
      bottom = Float64::MIN

      @quads.each do |quad|
        Cdp::DOM.each_point(quad) do |point|
          left = point.x if point.x < left
          top = point.y if point.y < top
          right = point.x if point.x > right
          bottom = point.y if point.y > bottom
        end
      end

      Rect.from_json({
        "x"      => left,
        "y"      => top,
        "width"  => right - left,
        "height" => bottom - top,
      }.to_json)
    end
  end

  struct GetDocumentResult
    include JSON::Serializable
    @[JSON::Field(key: "root", emit_null: false)]
    property root : Node

    def initialize(@root : Node)
    end
  end

  @[Experimental]
  struct GetNodesForSubtreeByStyleResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  struct GetNodeForLocationResult
    include JSON::Serializable
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?

    def initialize(@backend_node_id : BackendNodeId, @frame_id : Cdp::Page::FrameId, @node_id : NodeId?)
    end
  end

  struct GetOuterHTMLResult
    include JSON::Serializable
    @[JSON::Field(key: "outerHtml", emit_null: false)]
    property outer_html : String

    def initialize(@outer_html : String)
    end
  end

  @[Experimental]
  struct GetRelayoutBoundaryResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct GetSearchResultsResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  struct MoveToResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct PerformSearchResult
    include JSON::Serializable
    @[JSON::Field(key: "searchId", emit_null: false)]
    property search_id : String
    @[JSON::Field(key: "resultCount", emit_null: false)]
    property result_count : Int64

    def initialize(@search_id : String, @result_count : Int64)
    end
  end

  @[Experimental]
  struct PushNodeByPathToFrontendResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct PushNodesByBackendIdsToFrontendResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  struct QuerySelectorResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct QuerySelectorAllResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  @[Experimental]
  struct GetTopLayerElementsResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  @[Experimental]
  struct GetElementByRelationResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct RequestNodeResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  struct ResolveNodeResult
    include JSON::Serializable
    @[JSON::Field(key: "object", emit_null: false)]
    property object : Cdp::Runtime::RemoteObject

    def initialize(@object : Cdp::Runtime::RemoteObject)
    end
  end

  @[Experimental]
  struct GetNodeStackTracesResult
    include JSON::Serializable
    @[JSON::Field(key: "creation", emit_null: false)]
    property creation : Cdp::Runtime::StackTrace?

    def initialize(@creation : Cdp::Runtime::StackTrace?)
    end
  end

  @[Experimental]
  struct GetFileInfoResult
    include JSON::Serializable
    @[JSON::Field(key: "path", emit_null: false)]
    property path : String

    def initialize(@path : String)
    end
  end

  @[Experimental]
  struct GetDetachedDomNodesResult
    include JSON::Serializable
    @[JSON::Field(key: "detachedNodes", emit_null: false)]
    property detached_nodes : Array(DetachedElementInfo)

    def initialize(@detached_nodes : Array(DetachedElementInfo))
    end
  end

  struct SetNodeNameResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct GetFrameOwnerResult
    include JSON::Serializable
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?

    def initialize(@backend_node_id : BackendNodeId, @node_id : NodeId?)
    end
  end

  @[Experimental]
  struct GetContainerForNodeResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?

    def initialize(@node_id : NodeId?)
    end
  end

  @[Experimental]
  struct GetQueryingDescendantsForContainerResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  @[Experimental]
  struct GetAnchorElementResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end
  end

  @[Experimental]
  struct ForceShowPopoverResult
    include JSON::Serializable
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end
  end

  # Commands
  @[Experimental]
  struct CollectClassNamesFromSubtree
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.collectClassNamesFromSubtree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CollectClassNamesFromSubtreeResult
      Cdp.call(proto_req, self, CollectClassNamesFromSubtreeResult, c)
    end
  end

  @[Experimental]
  struct CopyTo
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "targetNodeId", emit_null: false)]
    property target_node_id : NodeId
    @[JSON::Field(key: "insertBeforeNodeId", emit_null: false)]
    property insert_before_node_id : NodeId?

    def initialize(@node_id : NodeId, @target_node_id : NodeId, @insert_before_node_id : NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.copyTo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CopyToResult
      Cdp.call(proto_req, self, CopyToResult, c)
    end
  end

  struct DescribeNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(key: "depth", emit_null: false)]
    property depth : Int64?
    @[JSON::Field(key: "pierce", emit_null: false)]
    property? pierce : Bool?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?, @depth : Int64?, @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.describeNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : DescribeNodeResult
      Cdp.call(proto_req, self, DescribeNodeResult, c)
    end
  end

  struct ScrollIntoViewIfNeeded
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(key: "rect", emit_null: false)]
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

    def initialize
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
    @[JSON::Field(key: "searchId", emit_null: false)]
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
    @[JSON::Field(key: "includeWhitespace", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getAttributes"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAttributesResult
      Cdp.call(proto_req, self, GetAttributesResult, c)
    end
  end

  struct GetBoxModel
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getBoxModel"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBoxModelResult
      Cdp.call(proto_req, self, GetBoxModelResult, c)
    end
  end

  @[Experimental]
  struct GetContentQuads
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getContentQuads"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetContentQuadsResult
      Cdp.call(proto_req, self, GetContentQuadsResult, c)
    end
  end

  struct GetDocument
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "depth", emit_null: false)]
    property depth : Int64?
    @[JSON::Field(key: "pierce", emit_null: false)]
    property? pierce : Bool?

    def initialize(@depth : Int64?, @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getDocument"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDocumentResult
      Cdp.call(proto_req, self, GetDocumentResult, c)
    end
  end

  @[Experimental]
  struct GetNodesForSubtreeByStyle
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "computedStyles", emit_null: false)]
    property computed_styles : Array(CSSComputedStyleProperty)
    @[JSON::Field(key: "pierce", emit_null: false)]
    property? pierce : Bool?

    def initialize(@node_id : NodeId, @computed_styles : Array(CSSComputedStyleProperty), @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getNodesForSubtreeByStyle"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNodesForSubtreeByStyleResult
      Cdp.call(proto_req, self, GetNodesForSubtreeByStyleResult, c)
    end
  end

  struct GetNodeForLocation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Int64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Int64
    @[JSON::Field(key: "includeUserAgentShadowDom", emit_null: false)]
    property? include_user_agent_shadow_dom : Bool?
    @[JSON::Field(key: "ignorePointerEventsNone", emit_null: false)]
    property? ignore_pointer_events_none : Bool?

    def initialize(@x : Int64, @y : Int64, @include_user_agent_shadow_dom : Bool?, @ignore_pointer_events_none : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getNodeForLocation"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNodeForLocationResult
      Cdp.call(proto_req, self, GetNodeForLocationResult, c)
    end
  end

  struct GetOuterHTML
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(key: "includeShadowDom", emit_null: false)]
    property? include_shadow_dom : Bool?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?, @include_shadow_dom : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getOuterHTML"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetOuterHTMLResult
      Cdp.call(proto_req, self, GetOuterHTMLResult, c)
    end
  end

  @[Experimental]
  struct GetRelayoutBoundary
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getRelayoutBoundary"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetRelayoutBoundaryResult
      Cdp.call(proto_req, self, GetRelayoutBoundaryResult, c)
    end
  end

  @[Experimental]
  struct GetSearchResults
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "searchId", emit_null: false)]
    property search_id : String
    @[JSON::Field(key: "fromIndex", emit_null: false)]
    property from_index : Int64
    @[JSON::Field(key: "toIndex", emit_null: false)]
    property to_index : Int64

    def initialize(@search_id : String, @from_index : Int64, @to_index : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getSearchResults"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSearchResultsResult
      Cdp.call(proto_req, self, GetSearchResultsResult, c)
    end
  end

  @[Experimental]
  struct MarkUndoableState
    include JSON::Serializable
    include Cdp::Request

    def initialize
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "targetNodeId", emit_null: false)]
    property target_node_id : NodeId
    @[JSON::Field(key: "insertBeforeNodeId", emit_null: false)]
    property insert_before_node_id : NodeId?

    def initialize(@node_id : NodeId, @target_node_id : NodeId, @insert_before_node_id : NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.moveTo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : MoveToResult
      Cdp.call(proto_req, self, MoveToResult, c)
    end
  end

  @[Experimental]
  struct PerformSearch
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "query", emit_null: false)]
    property query : String
    @[JSON::Field(key: "includeUserAgentShadowDom", emit_null: false)]
    property? include_user_agent_shadow_dom : Bool?

    def initialize(@query : String, @include_user_agent_shadow_dom : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.performSearch"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PerformSearchResult
      Cdp.call(proto_req, self, PerformSearchResult, c)
    end
  end

  @[Experimental]
  struct PushNodeByPathToFrontend
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "path", emit_null: false)]
    property path : String

    def initialize(@path : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.pushNodeByPathToFrontend"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PushNodeByPathToFrontendResult
      Cdp.call(proto_req, self, PushNodeByPathToFrontendResult, c)
    end
  end

  @[Experimental]
  struct PushNodesByBackendIdsToFrontend
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "backendNodeIds", emit_null: false)]
    property backend_node_ids : Array(BackendNodeId)

    def initialize(@backend_node_ids : Array(BackendNodeId))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.pushNodesByBackendIdsToFrontend"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PushNodesByBackendIdsToFrontendResult
      Cdp.call(proto_req, self, PushNodesByBackendIdsToFrontendResult, c)
    end
  end

  struct QuerySelector
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "selector", emit_null: false)]
    property selector : String

    def initialize(@node_id : NodeId, @selector : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.querySelector"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : QuerySelectorResult
      Cdp.call(proto_req, self, QuerySelectorResult, c)
    end
  end

  struct QuerySelectorAll
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "selector", emit_null: false)]
    property selector : String

    def initialize(@node_id : NodeId, @selector : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.querySelectorAll"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : QuerySelectorAllResult
      Cdp.call(proto_req, self, QuerySelectorAllResult, c)
    end
  end

  @[Experimental]
  struct GetTopLayerElements
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getTopLayerElements"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetTopLayerElementsResult
      Cdp.call(proto_req, self, GetTopLayerElementsResult, c)
    end
  end

  @[Experimental]
  struct GetElementByRelation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "relation", emit_null: false)]
    property relation : GetElementByRelationRelation

    def initialize(@node_id : NodeId, @relation : GetElementByRelationRelation)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getElementByRelation"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetElementByRelationResult
      Cdp.call(proto_req, self, GetElementByRelationResult, c)
    end
  end

  @[Experimental]
  struct Redo
    include JSON::Serializable
    include Cdp::Request

    def initialize
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "name", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "depth", emit_null: false)]
    property depth : Int64?
    @[JSON::Field(key: "pierce", emit_null: false)]
    property? pierce : Bool?

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
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.requestNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestNodeResult
      Cdp.call(proto_req, self, RequestNodeResult, c)
    end
  end

  struct ResolveNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectGroup", emit_null: false)]
    property object_group : String?
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : Cdp::Runtime::ExecutionContextId?

    def initialize(@node_id : NodeId?, @backend_node_id : BackendNodeId?, @object_group : String?, @execution_context_id : Cdp::Runtime::ExecutionContextId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.resolveNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ResolveNodeResult
      Cdp.call(proto_req, self, ResolveNodeResult, c)
    end
  end

  struct SetAttributeValue
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "name", emit_null: false)]
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
    @[JSON::Field(key: "files", emit_null: false)]
    property files : Array(String)
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : BackendNodeId?
    @[JSON::Field(key: "objectId", emit_null: false)]
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
    @[JSON::Field(key: "enable", emit_null: false)]
    property? enable : Bool

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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getNodeStackTraces"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNodeStackTracesResult
      Cdp.call(proto_req, self, GetNodeStackTracesResult, c)
    end
  end

  @[Experimental]
  struct GetFileInfo
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getFileInfo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFileInfoResult
      Cdp.call(proto_req, self, GetFileInfoResult, c)
    end
  end

  @[Experimental]
  struct GetDetachedDomNodes
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getDetachedDomNodes"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDetachedDomNodesResult
      Cdp.call(proto_req, self, GetDetachedDomNodesResult, c)
    end
  end

  @[Experimental]
  struct SetInspectedNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String

    def initialize(@node_id : NodeId, @name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.setNodeName"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetNodeNameResult
      Cdp.call(proto_req, self, SetNodeNameResult, c)
    end
  end

  struct SetNodeValue
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "value", emit_null: false)]
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
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "outerHtml", emit_null: false)]
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

    def initialize
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
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId

    def initialize(@frame_id : Cdp::Page::FrameId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getFrameOwner"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFrameOwnerResult
      Cdp.call(proto_req, self, GetFrameOwnerResult, c)
    end
  end

  @[Experimental]
  struct GetContainerForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "containerName", emit_null: false)]
    property container_name : String?
    @[JSON::Field(key: "physicalAxes", emit_null: false)]
    property physical_axes : PhysicalAxes?
    @[JSON::Field(key: "logicalAxes", emit_null: false)]
    property logical_axes : LogicalAxes?
    @[JSON::Field(key: "queriesScrollState", emit_null: false)]
    property? queries_scroll_state : Bool?
    @[JSON::Field(key: "queriesAnchored", emit_null: false)]
    property? queries_anchored : Bool?

    def initialize(@node_id : NodeId, @container_name : String?, @physical_axes : PhysicalAxes?, @logical_axes : LogicalAxes?, @queries_scroll_state : Bool?, @queries_anchored : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getContainerForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetContainerForNodeResult
      Cdp.call(proto_req, self, GetContainerForNodeResult, c)
    end
  end

  @[Experimental]
  struct GetQueryingDescendantsForContainer
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId

    def initialize(@node_id : NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getQueryingDescendantsForContainer"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetQueryingDescendantsForContainerResult
      Cdp.call(proto_req, self, GetQueryingDescendantsForContainerResult, c)
    end
  end

  @[Experimental]
  struct GetAnchorElement
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "anchorSpecifier", emit_null: false)]
    property anchor_specifier : String?

    def initialize(@node_id : NodeId, @anchor_specifier : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.getAnchorElement"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAnchorElementResult
      Cdp.call(proto_req, self, GetAnchorElementResult, c)
    end
  end

  @[Experimental]
  struct ForceShowPopover
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "enable", emit_null: false)]
    property? enable : Bool

    def initialize(@node_id : NodeId, @enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOM.forceShowPopover"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ForceShowPopoverResult
      Cdp.call(proto_req, self, ForceShowPopoverResult, c)
    end
  end
end

module Cdp::DOM
  def self.quad_to_floats(quad : Quad) : Array(Float64)
    quad.as_a.map(&.as_f)
  end

  def self.each_point(quad : Quad, & : Point ->) : Nil
    arr = quad_to_floats(quad)
    size = arr.size // 2
    (0...size).each do |i|
      yield Point.new(arr[i * 2], arr[i * 2 + 1])
    end
  end

  # Center returns average point of quad vertices.
  def self.center(quad : Quad) : Point
    total_x = 0.0
    total_y = 0.0
    count = 0
    each_point(quad) do |point|
      total_x += point.x
      total_y += point.y
      count += 1
    end
    Point.new(total_x / count, total_y / count)
  end

  # Area computes polygon area using shoelace formula.
  def self.area(quad : Quad) : Float64
    arr = quad_to_floats(quad)
    n = arr.size // 2
    sum = 0.0
    (0...n).each do |i|
      x1 = arr[i * 2]
      y1 = arr[i * 2 + 1]
      x2 = arr[((i + 1) % n) * 2]
      y2 = arr[((i + 1) % n) * 2 + 1]
      sum += x1 * y2 - x2 * y1
    end
    sum.abs / 2.0
  end
end
