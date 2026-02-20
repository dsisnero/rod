require "../page/page"
require "json"
require "time"
require "../runtime/runtime"
require "../dom/dom"
require "../network/network"
require "../io/io"

module Cdp::Page
  struct DomContentEventFiredEvent
    include JSON::Serializable
    include Cdp::Event

    property timestamp : Cdp::Network::MonotonicTime

    def initialize(@timestamp : Cdp::Network::MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.domContentEventFired"
    end
  end

  struct FileChooserOpenedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property mode : FileChooserOpenedMode
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?

    def initialize(@frame_id : FrameId, @mode : FileChooserOpenedMode, @backend_node_id : Cdp::DOM::BackendNodeId?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.fileChooserOpened"
    end
  end

  struct FrameAttachedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property parent_frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property stack : Cdp::Runtime::StackTrace?

    def initialize(@frame_id : FrameId, @parent_frame_id : FrameId, @stack : Cdp::Runtime::StackTrace?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameAttached"
    end
  end

  struct FrameDetachedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property reason : FrameDetachedReason

    def initialize(@frame_id : FrameId, @reason : FrameDetachedReason)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameDetached"
    end
  end

  @[Experimental]
  struct FrameSubtreeWillBeDetachedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId

    def initialize(@frame_id : FrameId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameSubtreeWillBeDetached"
    end
  end

  struct FrameNavigatedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame : Frame
    property type : NavigationType

    def initialize(@frame : Frame, @type : NavigationType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameNavigated"
    end
  end

  @[Experimental]
  struct DocumentOpenedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame : Frame

    def initialize(@frame : Frame)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.documentOpened"
    end
  end

  @[Experimental]
  struct FrameResizedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameResized"
    end
  end

  @[Experimental]
  struct FrameStartedNavigatingEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property url : String
    property loader_id : Cdp::Network::LoaderId
    property navigation_type : FrameStartedNavigatingNavigationType

    def initialize(@frame_id : FrameId, @url : String, @loader_id : Cdp::Network::LoaderId, @navigation_type : FrameStartedNavigatingNavigationType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameStartedNavigating"
    end
  end

  @[Experimental]
  struct FrameRequestedNavigationEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property reason : ClientNavigationReason
    property url : String
    property disposition : ClientNavigationDisposition

    def initialize(@frame_id : FrameId, @reason : ClientNavigationReason, @url : String, @disposition : ClientNavigationDisposition)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameRequestedNavigation"
    end
  end

  @[Experimental]
  struct FrameStartedLoadingEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId

    def initialize(@frame_id : FrameId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameStartedLoading"
    end
  end

  @[Experimental]
  struct FrameStoppedLoadingEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId

    def initialize(@frame_id : FrameId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameStoppedLoading"
    end
  end

  struct InterstitialHiddenEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.interstitialHidden"
    end
  end

  struct InterstitialShownEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.interstitialShown"
    end
  end

  struct JavascriptDialogClosedEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property result : Bool
    property user_input : String

    def initialize(@frame_id : FrameId, @result : Bool, @user_input : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.javascriptDialogClosed"
    end
  end

  struct JavascriptDialogOpeningEvent
    include JSON::Serializable
    include Cdp::Event

    property url : String
    property frame_id : FrameId
    property message : String
    property type : DialogType
    property has_browser_handler : Bool
    @[JSON::Field(emit_null: false)]
    property default_prompt : String?

    def initialize(@url : String, @frame_id : FrameId, @message : String, @type : DialogType, @has_browser_handler : Bool, @default_prompt : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.javascriptDialogOpening"
    end
  end

  struct LifecycleEventEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property loader_id : Cdp::Network::LoaderId
    property name : String
    property timestamp : Cdp::Network::MonotonicTime

    def initialize(@frame_id : FrameId, @loader_id : Cdp::Network::LoaderId, @name : String, @timestamp : Cdp::Network::MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.lifecycleEvent"
    end
  end

  @[Experimental]
  struct BackForwardCacheNotUsedEvent
    include JSON::Serializable
    include Cdp::Event

    property loader_id : Cdp::Network::LoaderId
    property frame_id : FrameId
    property not_restored_explanations : Array(BackForwardCacheNotRestoredExplanation)
    @[JSON::Field(emit_null: false)]
    property not_restored_explanations_tree : BackForwardCacheNotRestoredExplanationTree?

    def initialize(@loader_id : Cdp::Network::LoaderId, @frame_id : FrameId, @not_restored_explanations : Array(BackForwardCacheNotRestoredExplanation), @not_restored_explanations_tree : BackForwardCacheNotRestoredExplanationTree?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.backForwardCacheNotUsed"
    end
  end

  struct LoadEventFiredEvent
    include JSON::Serializable
    include Cdp::Event

    property timestamp : Cdp::Network::MonotonicTime

    def initialize(@timestamp : Cdp::Network::MonotonicTime)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.loadEventFired"
    end
  end

  @[Experimental]
  struct NavigatedWithinDocumentEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : FrameId
    property url : String
    property navigation_type : NavigatedWithinDocumentNavigationType

    def initialize(@frame_id : FrameId, @url : String, @navigation_type : NavigatedWithinDocumentNavigationType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.navigatedWithinDocument"
    end
  end

  @[Experimental]
  struct ScreencastFrameEvent
    include JSON::Serializable
    include Cdp::Event

    property data : String
    property metadata : ScreencastFrameMetadata
    property session_id : Int64

    def initialize(@data : String, @metadata : ScreencastFrameMetadata, @session_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.screencastFrame"
    end
  end

  @[Experimental]
  struct ScreencastVisibilityChangedEvent
    include JSON::Serializable
    include Cdp::Event

    property visible : Bool

    def initialize(@visible : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.screencastVisibilityChanged"
    end
  end

  struct WindowOpenEvent
    include JSON::Serializable
    include Cdp::Event

    property url : String
    property window_name : String
    property window_features : Array(String)
    property user_gesture : Bool

    def initialize(@url : String, @window_name : String, @window_features : Array(String), @user_gesture : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.windowOpen"
    end
  end

  @[Experimental]
  struct CompilationCacheProducedEvent
    include JSON::Serializable
    include Cdp::Event

    property url : String
    property data : String

    def initialize(@url : String, @data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.compilationCacheProduced"
    end
  end
end
