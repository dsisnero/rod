require "../cdp"
require "json"
require "time"

require "../log/log"
require "../page/page"

module Cdp::HAR
  struct Cache
    include JSON::Serializable
    @[JSON::Field(key: "beforeRequest", emit_null: false)]
    property before_request : CacheData?
    @[JSON::Field(key: "afterRequest", emit_null: false)]
    property after_request : CacheData?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct CacheData
    include JSON::Serializable
    @[JSON::Field(key: "expires", emit_null: false)]
    property expires : String?
    @[JSON::Field(key: "lastAccess", emit_null: false)]
    property last_access : String
    @[JSON::Field(key: "eTag", emit_null: false)]
    property e_tag : String
    @[JSON::Field(key: "hitCount", emit_null: false)]
    property hit_count : Int64
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Content
    include JSON::Serializable
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Int64
    @[JSON::Field(key: "compression", emit_null: false)]
    property compression : Int64?
    @[JSON::Field(key: "mimeType", emit_null: false)]
    property mime_type : String
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String?
    @[JSON::Field(key: "encoding", emit_null: false)]
    property encoding : String?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Cookie
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "path", emit_null: false)]
    property path : String?
    @[JSON::Field(key: "domain", emit_null: false)]
    property domain : String?
    @[JSON::Field(key: "expires", emit_null: false)]
    property expires : String?
    @[JSON::Field(key: "httpOnly", emit_null: false)]
    property? http_only : Bool?
    @[JSON::Field(key: "secure", emit_null: false)]
    property? secure : Bool?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Creator
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Entry
    include JSON::Serializable
    @[JSON::Field(key: "pageref", emit_null: false)]
    property pageref : String?
    @[JSON::Field(key: "startedDateTime", emit_null: false)]
    property started_date_time : String
    @[JSON::Field(key: "time", emit_null: false)]
    property time : Float64
    @[JSON::Field(key: "request", emit_null: false)]
    property request : Request
    @[JSON::Field(key: "response", emit_null: false)]
    property response : Response
    @[JSON::Field(key: "cache", emit_null: false)]
    property cache : Cache
    @[JSON::Field(key: "timings", emit_null: false)]
    property timings : Timings
    @[JSON::Field(key: "serverIpAddress", emit_null: false)]
    property server_ip_address : String?
    @[JSON::Field(key: "connection", emit_null: false)]
    property connection : String?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct HAR
    include JSON::Serializable
    @[JSON::Field(key: "log", emit_null: false)]
    property log : Log
  end

  struct Log
    include JSON::Serializable
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String
    @[JSON::Field(key: "creator", emit_null: false)]
    property creator : Creator
    @[JSON::Field(key: "browser", emit_null: false)]
    property browser : Creator?
    @[JSON::Field(key: "pages", emit_null: false)]
    property pages : Array(Page)?
    @[JSON::Field(key: "entries", emit_null: false)]
    property entries : Array(Entry)
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct NameValuePair
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Page
    include JSON::Serializable
    @[JSON::Field(key: "startedDateTime", emit_null: false)]
    property started_date_time : String
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String
    @[JSON::Field(key: "pageTimings", emit_null: false)]
    property page_timings : PageTimings
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct PageTimings
    include JSON::Serializable
    @[JSON::Field(key: "onContentLoad", emit_null: false)]
    property on_content_load : Float64?
    @[JSON::Field(key: "onLoad", emit_null: false)]
    property on_load : Float64?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Param
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String?
    @[JSON::Field(key: "fileName", emit_null: false)]
    property file_name : String?
    @[JSON::Field(key: "contentType", emit_null: false)]
    property content_type : String?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct PostData
    include JSON::Serializable
    @[JSON::Field(key: "mimeType", emit_null: false)]
    property mime_type : String
    @[JSON::Field(key: "params", emit_null: false)]
    property params : Array(Param)
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Request
    include JSON::Serializable
    @[JSON::Field(key: "method", emit_null: false)]
    property method : String
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "httpVersion", emit_null: false)]
    property http_version : String
    @[JSON::Field(key: "cookies", emit_null: false)]
    property cookies : Array(Cookie)
    @[JSON::Field(key: "headers", emit_null: false)]
    property headers : Array(NameValuePair)
    @[JSON::Field(key: "queryString", emit_null: false)]
    property query_string : Array(NameValuePair)
    @[JSON::Field(key: "postData", emit_null: false)]
    property post_data : PostData?
    @[JSON::Field(key: "headersSize", emit_null: false)]
    property headers_size : Int64
    @[JSON::Field(key: "bodySize", emit_null: false)]
    property body_size : Int64
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Response
    include JSON::Serializable
    @[JSON::Field(key: "status", emit_null: false)]
    property status : Int64
    @[JSON::Field(key: "statusText", emit_null: false)]
    property status_text : String
    @[JSON::Field(key: "httpVersion", emit_null: false)]
    property http_version : String
    @[JSON::Field(key: "cookies", emit_null: false)]
    property cookies : Array(Cookie)
    @[JSON::Field(key: "headers", emit_null: false)]
    property headers : Array(NameValuePair)
    @[JSON::Field(key: "content", emit_null: false)]
    property content : Content
    @[JSON::Field(key: "redirectUrl", emit_null: false)]
    property redirect_url : String
    @[JSON::Field(key: "headersSize", emit_null: false)]
    property headers_size : Int64
    @[JSON::Field(key: "bodySize", emit_null: false)]
    property body_size : Int64
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end

  struct Timings
    include JSON::Serializable
    @[JSON::Field(key: "blocked", emit_null: false)]
    property blocked : Float64?
    @[JSON::Field(key: "dns", emit_null: false)]
    property dns : Float64?
    @[JSON::Field(key: "connect", emit_null: false)]
    property connect : Float64?
    @[JSON::Field(key: "send", emit_null: false)]
    property send : Float64
    @[JSON::Field(key: "wait", emit_null: false)]
    property wait : Float64
    @[JSON::Field(key: "receive", emit_null: false)]
    property receive : Float64
    @[JSON::Field(key: "ssl", emit_null: false)]
    property ssl : Float64?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?
  end
end
