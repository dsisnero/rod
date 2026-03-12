require "../cdp"
require "json"

# Schema domain (deprecated in CDP, retained for Go proto compatibility).
module Cdp::Schema
  struct Domain
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String

    def initialize(@name : String, @version : String)
    end
  end

  struct GetDomains
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    def proto_req : String
      "Schema.getDomains"
    end

    def call(c : Cdp::Client) : GetDomainsResult
      Cdp.call(proto_req, self, GetDomainsResult, c)
    end
  end

  struct GetDomainsResult
    include JSON::Serializable
    @[JSON::Field(key: "domains", emit_null: false)]
    property domains : Array(Domain)

    def initialize(@domains : Array(Domain))
    end
  end
end
