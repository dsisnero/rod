
require "../cdp"
require "json"
require "time"


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
    property execution_context_id : ExecutionContextId

    def initialize(@name : String, @payload : String, @execution_context_id : ExecutionContextId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.bindingCalled"
    end
  end

  struct ConsoleAPICalledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property type : APIType
    @[JSON::Field(emit_null: false)]
    property args : Array(RemoteObject)
    @[JSON::Field(emit_null: false)]
    property execution_context_id : ExecutionContextId
    @[JSON::Field(emit_null: false)]
    property timestamp : Timestamp
    @[JSON::Field(emit_null: false)]
    property stack_trace : StackTrace?
    @[JSON::Field(emit_null: false)]
    property context : String?

    def initialize(@type : APIType, @args : Array(RemoteObject), @execution_context_id : ExecutionContextId, @timestamp : Timestamp, @stack_trace : StackTrace?, @context : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
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
  end

  struct ExceptionThrownEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property timestamp : Timestamp
    @[JSON::Field(emit_null: false)]
    property exception_details : ExceptionDetails

    def initialize(@timestamp : Timestamp, @exception_details : ExceptionDetails)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.exceptionThrown"
    end
  end

  struct ExecutionContextCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context : ExecutionContextDescription

    def initialize(@context : ExecutionContextDescription)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.executionContextCreated"
    end
  end

  struct ExecutionContextDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property execution_context_id : ExecutionContextId
    @[JSON::Field(emit_null: false)]
    property execution_context_unique_id : String

    def initialize(@execution_context_id : ExecutionContextId, @execution_context_unique_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.executionContextDestroyed"
    end
  end

  struct ExecutionContextsClearedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize()
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.executionContextsCleared"
    end
  end

  struct InspectRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property object : RemoteObject
    @[JSON::Field(emit_null: false)]
    property hints : JSON::Any
    @[JSON::Field(emit_null: false)]
    property execution_context_id : ExecutionContextId?

    def initialize(@object : RemoteObject, @hints : JSON::Any, @execution_context_id : ExecutionContextId?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Runtime.inspectRequested"
    end
  end

end
