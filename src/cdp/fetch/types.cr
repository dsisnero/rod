require "../fetch/fetch"
require "json"
require "time"
require "../network/network"
require "../io/io"
require "../page/page"

module Cdp::Fetch
  alias RequestId = String

  alias RequestStage = String

  struct RequestPattern
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property url_pattern : String?
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::Network::ResourceType?
    @[JSON::Field(emit_null: false)]
    property request_stage : RequestStage?
  end

  struct HeaderEntry
    include JSON::Serializable

    property name : String
    property value : String
  end

  struct AuthChallenge
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property source : AuthChallengeSource?
    property origin : String
    property scheme : String
    property realm : String
  end

  struct AuthChallengeResponse
    include JSON::Serializable

    property response : AuthChallengeResponseResponse
    @[JSON::Field(emit_null: false)]
    property username : String?
    @[JSON::Field(emit_null: false)]
    property password : String?
  end

  alias AuthChallengeSource = String

  alias AuthChallengeResponseResponse = String
end
