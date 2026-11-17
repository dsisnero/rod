require "../cdp"
require "json"
require "base64"
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

    def initialize(@name : String, @last_modified : Cdp::Network::TimeSinceEpoch, @size : Float64, @type : String)
    end
  end

  struct Directory
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "nestedDirectories", emit_null: false)]
    property nested_directories : Array(String)
    @[JSON::Field(key: "nestedFiles", emit_null: false)]
    property nested_files : Array(File)

    def initialize(@name : String, @nested_directories : Array(String), @nested_files : Array(File))
    end
  end

  struct BucketFileSystemLocator
    include JSON::Serializable
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : Cdp::Storage::SerializedStorageKey
    @[JSON::Field(key: "bucketName", emit_null: false)]
    property bucket_name : String?
    @[JSON::Field(key: "pathComponents", emit_null: false)]
    property path_components : Array(String)

    def initialize(@storage_key : Cdp::Storage::SerializedStorageKey, @path_components : Array(String), @bucket_name : String? = nil)
    end
  end
end
