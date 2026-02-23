
require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../network/network"
require "../dom/dom"
require "../io/io"
require "../debugger/debugger"

module Cdp::Page
  struct DomContentEventFiredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame : Frame
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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

    def initialize()
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property reason : ClientNavigationReason
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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

    def initialize()
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.interstitialHidden"
    end
  end

  struct InterstitialShownEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize()
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.interstitialShown"
    end
  end

  struct JavascriptDialogClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property result : Bool
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property message : String
    @[JSON::Field(emit_null: false)]
    property type : DialogType
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property metadata : ScreencastFrameMetadata
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property window_name : String
    @[JSON::Field(emit_null: false)]
    property window_features : Array(String)
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@url : String, @data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.compilationCacheProduced"
    end
  end

end
