require "../runtime/runtime"
require "json"
require "time"

module Cdp::Runtime
  alias ScriptId = String

  struct SerializationOptions
    include JSON::Serializable

    property serialization : SerializationOptionsSerialization
    @[JSON::Field(emit_null: false)]
    property max_depth : Int64?
    @[JSON::Field(emit_null: false)]
    property additional_parameters : JSON::Any?
  end

  struct DeepSerializedValue
    include JSON::Serializable

    property type : DeepSerializedValueType
    @[JSON::Field(emit_null: false)]
    property value : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property object_id : String?
    @[JSON::Field(emit_null: false)]
    property weak_local_object_reference : Int64?
  end

  alias RemoteObjectId = String

  alias UnserializableValue = String

  struct RemoteObject
    include JSON::Serializable

    property type : Type
    @[JSON::Field(emit_null: false)]
    property subtype : Subtype?
    @[JSON::Field(emit_null: false)]
    property class_name : String?
    @[JSON::Field(emit_null: false)]
    property value : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property unserializable_value : UnserializableValue?
    @[JSON::Field(emit_null: false)]
    property description : String?
    @[JSON::Field(emit_null: false)]
    property deep_serialized_value : DeepSerializedValue?
    @[JSON::Field(emit_null: false)]
    property object_id : RemoteObjectId?
    @[JSON::Field(emit_null: false)]
    property preview : ObjectPreview?
    @[JSON::Field(emit_null: false)]
    property custom_preview : CustomPreview?
  end

  @[Experimental]
  struct CustomPreview
    include JSON::Serializable

    property header : String
    @[JSON::Field(emit_null: false)]
    property body_getter_id : RemoteObjectId?
  end

  @[Experimental]
  struct ObjectPreview
    include JSON::Serializable

    property type : Type
    @[JSON::Field(emit_null: false)]
    property subtype : Subtype?
    @[JSON::Field(emit_null: false)]
    property description : String?
    property overflow : Bool
    property properties : Array(PropertyPreview)
    @[JSON::Field(emit_null: false)]
    property entries : Array(EntryPreview)?
  end

  @[Experimental]
  struct PropertyPreview
    include JSON::Serializable

    property name : String
    property type : Type
    @[JSON::Field(emit_null: false)]
    property value : String?
    @[JSON::Field(emit_null: false)]
    property value_preview : ObjectPreview?
    @[JSON::Field(emit_null: false)]
    property subtype : Subtype?
  end

  @[Experimental]
  struct EntryPreview
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property key : ObjectPreview?
    property value : ObjectPreview
  end

  struct PropertyDescriptor
    include JSON::Serializable

    property name : String
    @[JSON::Field(emit_null: false)]
    property value : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property writable : Bool?
    @[JSON::Field(emit_null: false)]
    property get : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property set : RemoteObject?
    property configurable : Bool
    property enumerable : Bool
    @[JSON::Field(emit_null: false)]
    property was_thrown : Bool?
    @[JSON::Field(emit_null: false)]
    property is_own : Bool?
    @[JSON::Field(emit_null: false)]
    property symbol : RemoteObject?
  end

  struct InternalPropertyDescriptor
    include JSON::Serializable

    property name : String
    @[JSON::Field(emit_null: false)]
    property value : RemoteObject?
  end

  @[Experimental]
  struct PrivatePropertyDescriptor
    include JSON::Serializable

    property name : String
    @[JSON::Field(emit_null: false)]
    property value : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property get : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property set : RemoteObject?
  end

  struct CallArgument
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property value : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property unserializable_value : UnserializableValue?
    @[JSON::Field(emit_null: false)]
    property object_id : RemoteObjectId?
  end

  alias ExecutionContextId = Int64

  struct ExecutionContextDescription
    include JSON::Serializable

    property id : ExecutionContextId
    property origin : String
    property name : String
    property unique_id : String
    @[JSON::Field(emit_null: false)]
    property aux_data : JSON::Any?
  end

  struct ExceptionDetails
    include JSON::Serializable

    property exception_id : Int64
    property text : String
    property line_number : Int64
    property column_number : Int64
    @[JSON::Field(emit_null: false)]
    property script_id : ScriptId?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property stack_trace : StackTrace?
    @[JSON::Field(emit_null: false)]
    property exception : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property execution_context_id : ExecutionContextId?
    @[JSON::Field(emit_null: false)]
    property exception_meta_data : JSON::Any?
  end

  alias Timestamp = Time

  alias TimeDelta = Float64

  struct CallFrame
    include JSON::Serializable

    property function_name : String
    property script_id : ScriptId
    property url : String
    property line_number : Int64
    property column_number : Int64
  end

  struct StackTrace
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property description : String?
    property call_frames : Array(CallFrame)
    @[JSON::Field(emit_null: false)]
    property parent : StackTrace?
    @[JSON::Field(emit_null: false)]
    property parent_id : StackTraceId?
  end

  @[Experimental]
  alias UniqueDebuggerId = String

  @[Experimental]
  struct StackTraceId
    include JSON::Serializable

    property id : String
    @[JSON::Field(emit_null: false)]
    property debugger_id : UniqueDebuggerId?
  end

  alias SerializationOptionsSerialization = String

  alias DeepSerializedValueType = String

  alias Type = String

  alias Subtype = String

  alias APIType = String
end
