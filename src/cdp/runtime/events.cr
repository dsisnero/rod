require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Runtime
  @[Experimental]
  struct BindingCalledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property payload : String
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::NodeType

    def initialize(@name : String, @payload : String, @execution_context_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.bindingCalled"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.bindingCalled"
    end
  end

  struct ConsoleAPICalledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property args : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property stack_trace : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property context : String?

    def initialize(@type : Cdp::NodeType, @args : Array(Cdp::NodeType), @execution_context_id : Cdp::NodeType, @timestamp : Cdp::NodeType, @stack_trace : Cdp::NodeType?, @context : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.consoleAPICalled"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.consoleAPICalled"
    end
  end

  struct ExceptionRevokedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property reason : String
    @[JSON::Field(emit_null: false)]
    property exception_id : Int64

    def initialize(@reason : String, @exception_id : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.exceptionRevoked"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.exceptionRevoked"
    end
  end

  struct ExceptionThrownEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property exception_details : Cdp::NodeType

    def initialize(@timestamp : Cdp::NodeType, @exception_details : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.exceptionThrown"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.exceptionThrown"
    end
  end

  struct ExecutionContextCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context : Cdp::NodeType

    def initialize(@context : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.executionContextCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.executionContextCreated"
    end
  end

  struct ExecutionContextDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property execution_context_unique_id : String

    def initialize(@execution_context_id : Cdp::NodeType, @execution_context_unique_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.executionContextDestroyed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.executionContextDestroyed"
    end
  end

  struct ExecutionContextsClearedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.executionContextsCleared"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.executionContextsCleared"
    end
  end

  struct InspectRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property object : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property hints : JSON::Any
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::NodeType?

    def initialize(@object : Cdp::NodeType, @hints : JSON::Any, @execution_context_id : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.inspectRequested"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Runtime.inspectRequested"
    end
  end
end
