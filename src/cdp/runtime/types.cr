require "../cdp"
require "json"
require "time"

module Cdp::Runtime
  alias ScriptId = String

  struct SerializationOptions
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property serialization : SerializationOptionsSerialization
    @[JSON::Field(emit_null: false)]
    property max_depth : Int64?
    @[JSON::Field(emit_null: false)]
    property additional_parameters : JSON::Any?
  end

  struct DeepSerializedValue
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property header : String
    @[JSON::Field(emit_null: false)]
    property body_getter_id : RemoteObjectId?
  end

  @[Experimental]
  struct ObjectPreview
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Type
    @[JSON::Field(emit_null: false)]
    property subtype : Subtype?
    @[JSON::Field(emit_null: false)]
    property description : String?
    @[JSON::Field(emit_null: false)]
    property? overflow : Bool
    @[JSON::Field(emit_null: false)]
    property properties : Array(PropertyPreview)
    @[JSON::Field(emit_null: false)]
    property entries : Array(EntryPreview)?
  end

  @[Experimental]
  struct PropertyPreview
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property value : ObjectPreview
  end

  struct PropertyDescriptor
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property? writable : Bool?
    @[JSON::Field(emit_null: false)]
    property get : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property set : RemoteObject?
    @[JSON::Field(emit_null: false)]
    property? configurable : Bool
    @[JSON::Field(emit_null: false)]
    property? enumerable : Bool
    @[JSON::Field(emit_null: false)]
    property? was_thrown : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_own : Bool?
    @[JSON::Field(emit_null: false)]
    property symbol : RemoteObject?
  end

  struct InternalPropertyDescriptor
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : RemoteObject?
  end

  @[Experimental]
  struct PrivatePropertyDescriptor
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property id : ExecutionContextId
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property unique_id : String
    @[JSON::Field(emit_null: false)]
    property aux_data : JSON::Any?
  end

  struct ExceptionDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property exception_id : Int64
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
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

  # Error satisfies the error interface.
  def error : String
    String.build do |b|
      # TODO: watch script parsed events and match the ExceptionDetails.ScriptID
      # to the name/location of the actual code and display here
      b << "exception "
      b.inspect(e.text)
      b << " ("
      b << e.line_number
      b << ":"
      b << e.column_number
      b << ")"
      if obj = e.exception
        b << ": "
        b << obj.description
      end
    end
  end

  alias Timestamp = Time

  alias TimeDelta = Float64

  struct CallFrame
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property function_name : String
    @[JSON::Field(emit_null: false)]
    property script_id : ScriptId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64
  end

  struct StackTrace
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property description : String?
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property debugger_id : UniqueDebuggerId?
  end

  alias SerializationOptionsSerialization = String
  SerializationOptionsSerializationDeep   = "deep"
  SerializationOptionsSerializationJson   = "json"
  SerializationOptionsSerializationIdOnly = "idOnly"

  alias DeepSerializedValueType = String
  DeepSerializedValueTypeUndefined    = "undefined"
  DeepSerializedValueTypeNull         = "null"
  DeepSerializedValueTypeStringType   = "string"
  DeepSerializedValueTypeNumberType   = "number"
  DeepSerializedValueTypeBooleanType  = "boolean"
  DeepSerializedValueTypeBigint       = "bigint"
  DeepSerializedValueTypeRegexp       = "regexp"
  DeepSerializedValueTypeDate         = "date"
  DeepSerializedValueTypeSymbolType   = "symbol"
  DeepSerializedValueTypeArray        = "array"
  DeepSerializedValueTypeObjectType   = "object"
  DeepSerializedValueTypeFunctionType = "function"
  DeepSerializedValueTypeMap          = "map"
  DeepSerializedValueTypeSet          = "set"
  DeepSerializedValueTypeWeakmap      = "weakmap"
  DeepSerializedValueTypeWeakset      = "weakset"
  DeepSerializedValueTypeError        = "error"
  DeepSerializedValueTypeProxy        = "proxy"
  DeepSerializedValueTypePromise      = "promise"
  DeepSerializedValueTypeTypedarray   = "typedarray"
  DeepSerializedValueTypeArraybuffer  = "arraybuffer"
  DeepSerializedValueTypeNode         = "node"
  DeepSerializedValueTypeWindow       = "window"
  DeepSerializedValueTypeGenerator    = "generator"

  alias Type = String
  TypeObjectType   = "object"
  TypeFunctionType = "function"
  TypeUndefined    = "undefined"
  TypeStringType   = "string"
  TypeNumberType   = "number"
  TypeBooleanType  = "boolean"
  TypeSymbolType   = "symbol"
  TypeBigint       = "bigint"
  TypeAccessor     = "accessor"

  alias Subtype = String
  SubtypeArray             = "array"
  SubtypeNull              = "null"
  SubtypeNode              = "node"
  SubtypeRegexp            = "regexp"
  SubtypeDate              = "date"
  SubtypeMap               = "map"
  SubtypeSet               = "set"
  SubtypeWeakmap           = "weakmap"
  SubtypeWeakset           = "weakset"
  SubtypeIterator          = "iterator"
  SubtypeGenerator         = "generator"
  SubtypeError             = "error"
  SubtypeProxy             = "proxy"
  SubtypePromise           = "promise"
  SubtypeTypedarray        = "typedarray"
  SubtypeArraybuffer       = "arraybuffer"
  SubtypeDataview          = "dataview"
  SubtypeWebassemblymemory = "webassemblymemory"
  SubtypeWasmvalue         = "wasmvalue"
  SubtypeTrustedtype       = "trustedtype"

  alias ConsoleAPICalledType = String
  ConsoleAPICalledTypeLog                 = "log"
  ConsoleAPICalledTypeDebug               = "debug"
  ConsoleAPICalledTypeInfo                = "info"
  ConsoleAPICalledTypeError               = "error"
  ConsoleAPICalledTypeWarning             = "warning"
  ConsoleAPICalledTypeDir                 = "dir"
  ConsoleAPICalledTypeDirxml              = "dirxml"
  ConsoleAPICalledTypeTable               = "table"
  ConsoleAPICalledTypeTrace               = "trace"
  ConsoleAPICalledTypeClear               = "clear"
  ConsoleAPICalledTypeStartGroup          = "startGroup"
  ConsoleAPICalledTypeStartGroupCollapsed = "startGroupCollapsed"
  ConsoleAPICalledTypeEndGroup            = "endGroup"
  ConsoleAPICalledTypeAssert              = "assert"
  ConsoleAPICalledTypeProfile             = "profile"
  ConsoleAPICalledTypeProfileEnd          = "profileEnd"
  ConsoleAPICalledTypeCount               = "count"
  ConsoleAPICalledTypeTimeEnd             = "timeEnd"
end
