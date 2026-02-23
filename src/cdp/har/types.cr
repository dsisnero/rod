
require "../cdp"
require "json"
require "time"

require "../log/log"
require "../page/page"

module Cdp::HAR
  struct Cache
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property before_request : CacheData?
    @[JSON::Field(emit_null: false)]
    property after_request : CacheData?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct CacheData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property expires : String?
    @[JSON::Field(emit_null: false)]
    property last_access : String
    @[JSON::Field(emit_null: false)]
    property e_tag : String
    @[JSON::Field(emit_null: false)]
    property hit_count : Int64
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Content
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property size : Int64
    @[JSON::Field(emit_null: false)]
    property compression : Int64?
    @[JSON::Field(emit_null: false)]
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property text : String?
    @[JSON::Field(emit_null: false)]
    property encoding : String?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Cookie
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property path : String?
    @[JSON::Field(emit_null: false)]
    property domain : String?
    @[JSON::Field(emit_null: false)]
    property expires : String?
    @[JSON::Field(emit_null: false)]
    property http_only : Bool?
    @[JSON::Field(emit_null: false)]
    property secure : Bool?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Creator
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property version : String
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Entry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property pageref : String?
    @[JSON::Field(emit_null: false)]
    property started_date_time : String
    @[JSON::Field(emit_null: false)]
    property time : Float64
    @[JSON::Field(emit_null: false)]
    property request : Request
    @[JSON::Field(emit_null: false)]
    property response : Response
    @[JSON::Field(emit_null: false)]
    property cache : Cache
    @[JSON::Field(emit_null: false)]
    property timings : Timings
    @[JSON::Field(emit_null: false)]
    property server_ip_address : String?
    @[JSON::Field(emit_null: false)]
    property connection : String?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct HAR
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property log : Log
  end

  struct Log
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property version : String
    @[JSON::Field(emit_null: false)]
    property creator : Creator
    @[JSON::Field(emit_null: false)]
    property browser : Creator?
    @[JSON::Field(emit_null: false)]
    property pages : Array(Page)?
    @[JSON::Field(emit_null: false)]
    property entries : Array(Entry)
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct NameValuePair
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Page
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property started_date_time : String
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property page_timings : PageTimings
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct PageTimings
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property on_content_load : Float64?
    @[JSON::Field(emit_null: false)]
    property on_load : Float64?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Param
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String?
    @[JSON::Field(emit_null: false)]
    property file_name : String?
    @[JSON::Field(emit_null: false)]
    property content_type : String?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct PostData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property params : Array(Param)
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Request
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property method : String
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property http_version : String
    @[JSON::Field(emit_null: false)]
    property cookies : Array(Cookie)
    @[JSON::Field(emit_null: false)]
    property headers : Array(NameValuePair)
    @[JSON::Field(emit_null: false)]
    property query_string : Array(NameValuePair)
    @[JSON::Field(emit_null: false)]
    property post_data : PostData?
    @[JSON::Field(emit_null: false)]
    property headers_size : Int64
    @[JSON::Field(emit_null: false)]
    property body_size : Int64
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Response
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property status : Int64
    @[JSON::Field(emit_null: false)]
    property status_text : String
    @[JSON::Field(emit_null: false)]
    property http_version : String
    @[JSON::Field(emit_null: false)]
    property cookies : Array(Cookie)
    @[JSON::Field(emit_null: false)]
    property headers : Array(NameValuePair)
    @[JSON::Field(emit_null: false)]
    property content : Content
    @[JSON::Field(emit_null: false)]
    property redirect_url : String
    @[JSON::Field(emit_null: false)]
    property headers_size : Int64
    @[JSON::Field(emit_null: false)]
    property body_size : Int64
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Timings
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property blocked : Float64?
    @[JSON::Field(emit_null: false)]
    property dns : Float64?
    @[JSON::Field(emit_null: false)]
    property connect : Float64?
    @[JSON::Field(emit_null: false)]
    property send : Float64
    @[JSON::Field(emit_null: false)]
    property wait : Float64
    @[JSON::Field(emit_null: false)]
    property receive : Float64
    @[JSON::Field(emit_null: false)]
    property ssl : Float64?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

   end
