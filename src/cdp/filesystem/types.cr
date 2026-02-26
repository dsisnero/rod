require "../cdp"
require "json"
require "time"

require "../network/network"
require "../storage/storage"

module Cdp::FileSystem
  struct File
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "lastModified", emit_null: false)]
    property last_modified : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Float64
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String
  end

  struct Directory
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "nestedDirectories", emit_null: false)]
    property nested_directories : Array(String)
    @[JSON::Field(key: "nestedFiles", emit_null: false)]
    property nested_files : Array(File)
  end

  struct BucketFileSystemLocator
    include JSON::Serializable
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : Cdp::Storage::SerializedStorageKey
    @[JSON::Field(key: "bucketName", emit_null: false)]
    property bucket_name : String?
    @[JSON::Field(key: "pathComponents", emit_null: false)]
    property path_components : Array(String)
  end
end
