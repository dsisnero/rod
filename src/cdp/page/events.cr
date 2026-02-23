require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Page
  struct DomContentEventFiredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.domContentEventFired"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.domContentEventFired"
    end
  end

  struct FileChooserOpenedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property mode : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?

    def initialize(@frame_id : Cdp::NodeType, @mode : Cdp::NodeType, @backend_node_id : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.fileChooserOpened"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.fileChooserOpened"
    end
  end

  struct FrameAttachedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property parent_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property stack : Cdp::NodeType?

    def initialize(@frame_id : Cdp::NodeType, @parent_frame_id : Cdp::NodeType, @stack : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameAttached"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameAttached"
    end
  end

  struct FrameDetachedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property reason : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType, @reason : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameDetached"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameDetached"
    end
  end

  @[Experimental]
  struct FrameSubtreeWillBeDetachedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameSubtreeWillBeDetached"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameSubtreeWillBeDetached"
    end
  end

  struct FrameNavigatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType

    def initialize(@frame : Cdp::NodeType, @type : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameNavigated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameNavigated"
    end
  end

  @[Experimental]
  struct DocumentOpenedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame : Cdp::NodeType

    def initialize(@frame : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.documentOpened"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
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

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameResized"
    end
  end

  @[Experimental]
  struct FrameStartedNavigatingEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property navigation_type : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType, @url : String, @loader_id : Cdp::NodeType, @navigation_type : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameStartedNavigating"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameStartedNavigating"
    end
  end

  @[Experimental]
  struct FrameRequestedNavigationEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property disposition : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType, @reason : Cdp::NodeType, @url : String, @disposition : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameRequestedNavigation"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameRequestedNavigation"
    end
  end

  @[Experimental]
  struct FrameStartedLoadingEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameStartedLoading"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.frameStartedLoading"
    end
  end

  @[Experimental]
  struct FrameStoppedLoadingEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.frameStoppedLoading"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
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

    # Class method returning protocol event name.
    def self.proto_event : String
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

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.interstitialShown"
    end
  end

  struct JavascriptDialogClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? result : Bool
    @[JSON::Field(emit_null: false)]
    property user_input : String

    def initialize(@frame_id : Cdp::NodeType, @result : Bool, @user_input : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.javascriptDialogClosed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.javascriptDialogClosed"
    end
  end

  struct JavascriptDialogOpeningEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property message : String
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? has_browser_handler : Bool
    @[JSON::Field(emit_null: false)]
    property default_prompt : String?

    def initialize(@url : String, @frame_id : Cdp::NodeType, @message : String, @type : Cdp::NodeType, @has_browser_handler : Bool, @default_prompt : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.javascriptDialogOpening"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.javascriptDialogOpening"
    end
  end

  struct LifecycleEventEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType, @loader_id : Cdp::NodeType, @name : String, @timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.lifecycleEvent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.lifecycleEvent"
    end
  end

  @[Experimental]
  struct BackForwardCacheNotUsedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property not_restored_explanations : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property not_restored_explanations_tree : Cdp::NodeType?

    def initialize(@loader_id : Cdp::NodeType, @frame_id : Cdp::NodeType, @not_restored_explanations : Array(Cdp::NodeType), @not_restored_explanations_tree : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.backForwardCacheNotUsed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.backForwardCacheNotUsed"
    end
  end

  struct LoadEventFiredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType

    def initialize(@timestamp : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.loadEventFired"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.loadEventFired"
    end
  end

  @[Experimental]
  struct NavigatedWithinDocumentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property navigation_type : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType, @url : String, @navigation_type : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.navigatedWithinDocument"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
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
    property metadata : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property session_id : Int64

    def initialize(@data : String, @metadata : Cdp::NodeType, @session_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.screencastFrame"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.screencastFrame"
    end
  end

  @[Experimental]
  struct ScreencastVisibilityChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property? visible : Bool

    def initialize(@visible : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.screencastVisibilityChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
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
    property? user_gesture : Bool

    def initialize(@url : String, @window_name : String, @window_features : Array(String), @user_gesture : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Page.windowOpen"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
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

    # Class method returning protocol event name.
    def self.proto_event : String
      "Page.compilationCacheProduced"
    end
  end
end
