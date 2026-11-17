require "../cdp"
require "json"
require "base64"
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

    def initialize(@before_request : CacheData? = nil, @after_request : CacheData? = nil, @comment : String? = nil)
    end
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

    def initialize(@last_access : String, @e_tag : String, @hit_count : Int64, @expires : String? = nil, @comment : String? = nil)
    end
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

    def initialize(@size : Int64, @mime_type : String, @compression : Int64? = nil, @text : String? = nil, @encoding : String? = nil, @comment : String? = nil)
    end
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

    def initialize(@name : String, @value : String, @path : String? = nil, @domain : String? = nil, @expires : String? = nil, @http_only : Bool? = nil, @secure : Bool? = nil, @comment : String? = nil)
    end
  end

  struct Creator
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?

    def initialize(@name : String, @version : String, @comment : String? = nil)
    end
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
    @[JSON::Field(key: "serverIPAddress", emit_null: false)]
    property server_ip_address : String?
    @[JSON::Field(key: "connection", emit_null: false)]
    property connection : String?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?

    def initialize(@started_date_time : String, @time : Float64, @request : Request, @response : Response, @cache : Cache, @timings : Timings, @pageref : String? = nil, @server_ip_address : String? = nil, @connection : String? = nil, @comment : String? = nil)
    end
  end

  struct HAR
    include JSON::Serializable
    @[JSON::Field(key: "log", emit_null: false)]
    property log : Log

    def initialize(@log : Log)
    end
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

    def initialize(@version : String, @creator : Creator, @entries : Array(Entry), @browser : Creator? = nil, @pages : Array(Page)? = nil, @comment : String? = nil)
    end
  end

  struct NameValuePair
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?

    def initialize(@name : String, @value : String, @comment : String? = nil)
    end
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

    def initialize(@started_date_time : String, @id : String, @title : String, @page_timings : PageTimings, @comment : String? = nil)
    end
  end

  struct PageTimings
    include JSON::Serializable
    @[JSON::Field(key: "onContentLoad", emit_null: false)]
    property on_content_load : Float64?
    @[JSON::Field(key: "onLoad", emit_null: false)]
    property on_load : Float64?
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?

    def initialize(@on_content_load : Float64? = nil, @on_load : Float64? = nil, @comment : String? = nil)
    end
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

    def initialize(@name : String, @value : String? = nil, @file_name : String? = nil, @content_type : String? = nil, @comment : String? = nil)
    end
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

    def initialize(@mime_type : String, @params : Array(Param), @text : String, @comment : String? = nil)
    end
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

    def initialize(@method : String, @url : String, @http_version : String, @cookies : Array(Cookie), @headers : Array(NameValuePair), @query_string : Array(NameValuePair), @headers_size : Int64, @body_size : Int64, @post_data : PostData? = nil, @comment : String? = nil)
    end
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
    @[JSON::Field(key: "redirectURL", emit_null: false)]
    property redirect_url : String
    @[JSON::Field(key: "headersSize", emit_null: false)]
    property headers_size : Int64
    @[JSON::Field(key: "bodySize", emit_null: false)]
    property body_size : Int64
    @[JSON::Field(key: "comment", emit_null: false)]
    property comment : String?

    def initialize(@status : Int64, @status_text : String, @http_version : String, @cookies : Array(Cookie), @headers : Array(NameValuePair), @content : Content, @redirect_url : String, @headers_size : Int64, @body_size : Int64, @comment : String? = nil)
    end
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

    def initialize(@send : Float64, @wait : Float64, @receive : Float64, @blocked : Float64? = nil, @dns : Float64? = nil, @connect : Float64? = nil, @ssl : Float64? = nil, @comment : String? = nil)
    end
  end
end
