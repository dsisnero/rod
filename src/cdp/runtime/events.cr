require "../cdp"
require "json"
require "time"

module Cdp::Runtime
  @[Experimental]
  struct BindingCalledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "payload", emit_null: false)]
    property payload : String
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId

    def initialize(@name : String, @payload : String, @execution_context_id : ExecutionContextId)
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
    @[JSON::Field(key: "type", emit_null: false)]
    property type : ConsoleAPICalledType
    @[JSON::Field(key: "args", emit_null: false)]
    property args : Array(RemoteObject)
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : Timestamp
    @[JSON::Field(key: "stackTrace", emit_null: false)]
    property stack_trace : StackTrace?
    @[JSON::Field(key: "context", emit_null: false)]
    property context : String?

    def initialize(@type : ConsoleAPICalledType, @args : Array(RemoteObject), @execution_context_id : ExecutionContextId, @timestamp : Timestamp, @stack_trace : StackTrace?, @context : String?)
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
    @[JSON::Field(key: "reason", emit_null: false)]
    property reason : String
    @[JSON::Field(key: "exceptionId", emit_null: false)]
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
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : Timestamp
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails

    def initialize(@timestamp : Timestamp, @exception_details : ExceptionDetails)
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
    @[JSON::Field(key: "context", emit_null: false)]
    property context : ExecutionContextDescription

    def initialize(@context : ExecutionContextDescription)
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
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId
    @[JSON::Field(key: "executionContextUniqueId", emit_null: false)]
    property execution_context_unique_id : String

    def initialize(@execution_context_id : ExecutionContextId, @execution_context_unique_id : String)
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
    @[JSON::Field(key: "object", emit_null: false)]
    property object : RemoteObject
    @[JSON::Field(key: "hints", emit_null: false)]
    property hints : JSON::Any
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId?

    def initialize(@object : RemoteObject, @hints : JSON::Any, @execution_context_id : ExecutionContextId?)
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
