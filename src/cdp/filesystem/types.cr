require "../filesystem/filesystem"
require "json"
require "time"

module Cdp::FileSystem
  struct File
    include JSON::Serializable

    property name : String
    property last_modified : Cdp::Network::TimeSinceEpoch
    property size : Float64
    property type : String
  end

  struct Directory
    include JSON::Serializable

    property name : String
    property nested_directories : Array(String)
    property nested_files : Array(File)
  end

  struct BucketFileSystemLocator
    include JSON::Serializable

    property storage_key : Cdp::Storage::SerializedStorageKey
    @[JSON::Field(emit_null: false)]
    property bucket_name : String?
    property path_components : Array(String)
  end
end
