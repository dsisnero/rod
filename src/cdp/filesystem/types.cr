require "../cdp"
require "json"
require "time"

require "../network/network"
require "../storage/storage"

module Cdp::FileSystem
  struct File
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property last_modified : Cdp::Network::TimeSinceEpoch
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
    property nested_files : Array(File)
  end

  struct BucketFileSystemLocator
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property storage_key : Cdp::Storage::SerializedStorageKey
    @[JSON::Field(emit_null: false)]
    property bucket_name : String?
    @[JSON::Field(emit_null: false)]
    property path_components : Array(String)
  end
end
