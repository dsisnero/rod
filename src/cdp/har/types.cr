require "../har/har"
require "json"
require "time"

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
    property last_access : String
    property e_tag : String
    property hit_count : Int64
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Content
    include JSON::Serializable

    property size : Int64
    @[JSON::Field(emit_null: false)]
    property compression : Int64?
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

    property name : String
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

    property name : String
    property version : String
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Entry
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property pageref : String?
    property started_date_time : String
    property time : Float64
    property request : Request
    property response : Response
    property cache : Cache
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

    property log : Log
  end

  struct Log
    include JSON::Serializable

    property version : String
    property creator : Creator
    @[JSON::Field(emit_null: false)]
    property browser : Creator?
    @[JSON::Field(emit_null: false)]
    property pages : Array(Page)?
    property entries : Array(Entry)
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct NameValuePair
    include JSON::Serializable

    property name : String
    property value : String
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Page
    include JSON::Serializable

    property started_date_time : String
    property id : String
    property title : String
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

    property mime_type : String
    property params : Array(Param)
    property text : String
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Request
    include JSON::Serializable

    property method : String
    property url : String
    property http_version : String
    property cookies : Array(Cookie)
    property headers : Array(NameValuePair)
    property query_string : Array(NameValuePair)
    @[JSON::Field(emit_null: false)]
    property post_data : PostData?
    property headers_size : Int64
    property body_size : Int64
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end

  struct Response
    include JSON::Serializable

    property status : Int64
    property status_text : String
    property http_version : String
    property cookies : Array(Cookie)
    property headers : Array(NameValuePair)
    property content : Content
    property redirect_url : String
    property headers_size : Int64
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
    property send : Float64
    property wait : Float64
    property receive : Float64
    @[JSON::Field(emit_null: false)]
    property ssl : Float64?
    @[JSON::Field(emit_null: false)]
    property comment : String?
  end
end
