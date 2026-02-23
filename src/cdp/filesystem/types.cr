require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::FileSystem
  struct File
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property last_modified : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property size : Float64
    @[JSON::Field(emit_null: false)]
    property type : String
  end

  struct Directory
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property nested_directories : Array(String)
    @[JSON::Field(emit_null: false)]
    property nested_files : Array(Cdp::NodeType)
  end

  struct BucketFileSystemLocator
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property storage_key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property bucket_name : String?
    @[JSON::Field(emit_null: false)]
    property path_components : Array(String)
  end
end
