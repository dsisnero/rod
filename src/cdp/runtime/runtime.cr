require "../cdp"
require "json"
require "time"

require "./types"
require "./events"

# Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects.
# Evaluation results are returned as mirror object that expose object type, string representation
# and unique identifier that can be used for further object reference. Original objects are
# maintained in memory unless they are either explicitly released or are released along with the
# other objects in their object group.
module Cdp::Runtime
  struct AwaitPromiseResult
    include JSON::Serializable
    @[JSON::Field(key: "result", emit_null: false)]
    property result : RemoteObject
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@result : RemoteObject, @exception_details : ExceptionDetails?)
    end
  end

  struct CallFunctionOnResult
    include JSON::Serializable
    @[JSON::Field(key: "result", emit_null: false)]
    property result : RemoteObject
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@result : RemoteObject, @exception_details : ExceptionDetails?)
    end
  end

  struct CompileScriptResult
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : ScriptId?
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@script_id : ScriptId?, @exception_details : ExceptionDetails?)
    end
  end

  struct EvaluateResult
    include JSON::Serializable
    @[JSON::Field(key: "result", emit_null: false)]
    property result : RemoteObject
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@result : RemoteObject, @exception_details : ExceptionDetails?)
    end
  end

  @[Experimental]
  struct GetIsolateIdResult
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String

    def initialize(@id : String)
    end
  end

  @[Experimental]
  struct GetHeapUsageResult
    include JSON::Serializable
    @[JSON::Field(key: "usedSize", emit_null: false)]
    property used_size : Float64
    @[JSON::Field(key: "totalSize", emit_null: false)]
    property total_size : Float64
    @[JSON::Field(key: "embedderHeapUsedSize", emit_null: false)]
    property embedder_heap_used_size : Float64
    @[JSON::Field(key: "backingStorageSize", emit_null: false)]
    property backing_storage_size : Float64

    def initialize(@used_size : Float64, @total_size : Float64, @embedder_heap_used_size : Float64, @backing_storage_size : Float64)
    end
  end

  struct GetPropertiesResult
    include JSON::Serializable
    @[JSON::Field(key: "result", emit_null: false)]
    property result : Array(PropertyDescriptor)
    @[JSON::Field(key: "internalProperties", emit_null: false)]
    property internal_properties : Array(InternalPropertyDescriptor)?
    @[JSON::Field(key: "privateProperties", emit_null: false)]
    property private_properties : Array(PrivatePropertyDescriptor)?
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@result : Array(PropertyDescriptor), @internal_properties : Array(InternalPropertyDescriptor)?, @private_properties : Array(PrivatePropertyDescriptor)?, @exception_details : ExceptionDetails?)
    end
  end

  struct GlobalLexicalScopeNamesResult
    include JSON::Serializable
    @[JSON::Field(key: "names", emit_null: false)]
    property names : Array(String)

    def initialize(@names : Array(String))
    end
  end

  struct QueryObjectsResult
    include JSON::Serializable
    @[JSON::Field(key: "objects", emit_null: false)]
    property objects : RemoteObject

    def initialize(@objects : RemoteObject)
    end
  end

  struct RunScriptResult
    include JSON::Serializable
    @[JSON::Field(key: "result", emit_null: false)]
    property result : RemoteObject
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@result : RemoteObject, @exception_details : ExceptionDetails?)
    end
  end

  @[Experimental]
  struct GetExceptionDetailsResult
    include JSON::Serializable
    @[JSON::Field(key: "exceptionDetails", emit_null: false)]
    property exception_details : ExceptionDetails?

    def initialize(@exception_details : ExceptionDetails?)
    end
  end

  # Commands
  struct AwaitPromise
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "promiseObjectId", emit_null: false)]
    property promise_object_id : RemoteObjectId
    @[JSON::Field(key: "returnByValue", emit_null: false)]
    property? return_by_value : Bool?
    @[JSON::Field(key: "generatePreview", emit_null: false)]
    property? generate_preview : Bool?

    def initialize(@promise_object_id : RemoteObjectId, @return_by_value : Bool?, @generate_preview : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.awaitPromise"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AwaitPromiseResult
      res = AwaitPromiseResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CallFunctionOn
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "functionDeclaration", emit_null: false)]
    property function_declaration : String
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : RemoteObjectId?
    @[JSON::Field(key: "arguments", emit_null: false)]
    property arguments : Array(CallArgument)?
    @[JSON::Field(key: "silent", emit_null: false)]
    property? silent : Bool?
    @[JSON::Field(key: "returnByValue", emit_null: false)]
    property? return_by_value : Bool?
    @[JSON::Field(key: "generatePreview", emit_null: false)]
    property? generate_preview : Bool?
    @[JSON::Field(key: "userGesture", emit_null: false)]
    property? user_gesture : Bool?
    @[JSON::Field(key: "awaitPromise", emit_null: false)]
    property? await_promise : Bool?
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId?
    @[JSON::Field(key: "objectGroup", emit_null: false)]
    property object_group : String?
    @[JSON::Field(key: "throwOnSideEffect", emit_null: false)]
    property? throw_on_side_effect : Bool?
    @[JSON::Field(key: "uniqueContextId", emit_null: false)]
    property unique_context_id : String?
    @[JSON::Field(key: "serializationOptions", emit_null: false)]
    property serialization_options : SerializationOptions?

    def initialize(@function_declaration : String, @object_id : RemoteObjectId?, @arguments : Array(CallArgument)?, @silent : Bool?, @return_by_value : Bool?, @generate_preview : Bool?, @user_gesture : Bool?, @await_promise : Bool?, @execution_context_id : ExecutionContextId?, @object_group : String?, @throw_on_side_effect : Bool?, @unique_context_id : String?, @serialization_options : SerializationOptions?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.callFunctionOn"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CallFunctionOnResult
      res = CallFunctionOnResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CompileScript
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "expression", emit_null: false)]
    property expression : String
    @[JSON::Field(key: "sourceUrl", emit_null: false)]
    property source_url : String
    @[JSON::Field(key: "persistScript", emit_null: false)]
    property? persist_script : Bool
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId?

    def initialize(@expression : String, @source_url : String, @persist_script : Bool, @execution_context_id : ExecutionContextId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.compileScript"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CompileScriptResult
      res = CompileScriptResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DiscardConsoleEntries
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.discardConsoleEntries"
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
      "Runtime.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Evaluate
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "expression", emit_null: false)]
    property expression : String
    @[JSON::Field(key: "objectGroup", emit_null: false)]
    property object_group : String?
    @[JSON::Field(key: "includeCommandLineApi", emit_null: false)]
    property? include_command_line_api : Bool?
    @[JSON::Field(key: "silent", emit_null: false)]
    property? silent : Bool?
    @[JSON::Field(key: "contextId", emit_null: false)]
    property context_id : ExecutionContextId?
    @[JSON::Field(key: "returnByValue", emit_null: false)]
    property? return_by_value : Bool?
    @[JSON::Field(key: "generatePreview", emit_null: false)]
    property? generate_preview : Bool?
    @[JSON::Field(key: "userGesture", emit_null: false)]
    property? user_gesture : Bool?
    @[JSON::Field(key: "awaitPromise", emit_null: false)]
    property? await_promise : Bool?
    @[JSON::Field(key: "throwOnSideEffect", emit_null: false)]
    property? throw_on_side_effect : Bool?
    @[JSON::Field(key: "timeout", emit_null: false)]
    property timeout : TimeDelta?
    @[JSON::Field(key: "disableBreaks", emit_null: false)]
    property? disable_breaks : Bool?
    @[JSON::Field(key: "replMode", emit_null: false)]
    property? repl_mode : Bool?
    @[JSON::Field(key: "allowUnsafeEvalBlockedByCsp", emit_null: false)]
    property? allow_unsafe_eval_blocked_by_csp : Bool?
    @[JSON::Field(key: "uniqueContextId", emit_null: false)]
    property unique_context_id : String?
    @[JSON::Field(key: "serializationOptions", emit_null: false)]
    property serialization_options : SerializationOptions?

    def initialize(@expression : String, @object_group : String?, @include_command_line_api : Bool?, @silent : Bool?, @context_id : ExecutionContextId?, @return_by_value : Bool?, @generate_preview : Bool?, @user_gesture : Bool?, @await_promise : Bool?, @throw_on_side_effect : Bool?, @timeout : TimeDelta?, @disable_breaks : Bool?, @repl_mode : Bool?, @allow_unsafe_eval_blocked_by_csp : Bool?, @unique_context_id : String?, @serialization_options : SerializationOptions?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.evaluate"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : EvaluateResult
      res = EvaluateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetIsolateId
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.getIsolateId"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetIsolateIdResult
      res = GetIsolateIdResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetHeapUsage
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.getHeapUsage"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetHeapUsageResult
      res = GetHeapUsageResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetProperties
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : RemoteObjectId
    @[JSON::Field(key: "ownProperties", emit_null: false)]
    property? own_properties : Bool?
    @[JSON::Field(key: "accessorPropertiesOnly", emit_null: false)]
    property? accessor_properties_only : Bool?
    @[JSON::Field(key: "generatePreview", emit_null: false)]
    property? generate_preview : Bool?
    @[JSON::Field(key: "nonIndexedPropertiesOnly", emit_null: false)]
    property? non_indexed_properties_only : Bool?

    def initialize(@object_id : RemoteObjectId, @own_properties : Bool?, @accessor_properties_only : Bool?, @generate_preview : Bool?, @non_indexed_properties_only : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.getProperties"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPropertiesResult
      res = GetPropertiesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GlobalLexicalScopeNames
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId?

    def initialize(@execution_context_id : ExecutionContextId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.globalLexicalScopeNames"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GlobalLexicalScopeNamesResult
      res = GlobalLexicalScopeNamesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct QueryObjects
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "prototypeObjectId", emit_null: false)]
    property prototype_object_id : RemoteObjectId
    @[JSON::Field(key: "objectGroup", emit_null: false)]
    property object_group : String?

    def initialize(@prototype_object_id : RemoteObjectId, @object_group : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.queryObjects"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : QueryObjectsResult
      res = QueryObjectsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ReleaseObject
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : RemoteObjectId

    def initialize(@object_id : RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.releaseObject"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReleaseObjectGroup
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "objectGroup", emit_null: false)]
    property object_group : String

    def initialize(@object_group : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.releaseObjectGroup"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RunIfWaitingForDebugger
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.runIfWaitingForDebugger"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RunScript
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : ScriptId
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId?
    @[JSON::Field(key: "objectGroup", emit_null: false)]
    property object_group : String?
    @[JSON::Field(key: "silent", emit_null: false)]
    property? silent : Bool?
    @[JSON::Field(key: "includeCommandLineApi", emit_null: false)]
    property? include_command_line_api : Bool?
    @[JSON::Field(key: "returnByValue", emit_null: false)]
    property? return_by_value : Bool?
    @[JSON::Field(key: "generatePreview", emit_null: false)]
    property? generate_preview : Bool?
    @[JSON::Field(key: "awaitPromise", emit_null: false)]
    property? await_promise : Bool?

    def initialize(@script_id : ScriptId, @execution_context_id : ExecutionContextId?, @object_group : String?, @silent : Bool?, @include_command_line_api : Bool?, @return_by_value : Bool?, @generate_preview : Bool?, @await_promise : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.runScript"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RunScriptResult
      res = RunScriptResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetCustomObjectFormatterEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.setCustomObjectFormatterEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetMaxCallStackSizeToCapture
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Int64

    def initialize(@size : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.setMaxCallStackSizeToCapture"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct TerminateExecution
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.terminateExecution"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddBinding
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "executionContextId", emit_null: false)]
    property execution_context_id : ExecutionContextId?
    @[JSON::Field(key: "executionContextName", emit_null: false)]
    property execution_context_name : String?

    def initialize(@name : String, @execution_context_id : ExecutionContextId?, @execution_context_name : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.addBinding"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveBinding
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String

    def initialize(@name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.removeBinding"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetExceptionDetails
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "errorObjectId", emit_null: false)]
    property error_object_id : RemoteObjectId

    def initialize(@error_object_id : RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Runtime.getExceptionDetails"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetExceptionDetailsResult
      res = GetExceptionDetailsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
