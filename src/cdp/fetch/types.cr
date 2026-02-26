require "../cdp"
require "json"
require "time"

require "../network/network"
require "../io/io"
require "../page/page"

module Cdp::Fetch
  alias RequestId = String

  alias RequestStage = String
  RequestStageRequest  = "Request"
  RequestStageResponse = "Response"

  struct RequestPattern
    include JSON::Serializable
    @[JSON::Field(key: "urlPattern", emit_null: false)]
    property url_pattern : String?
    @[JSON::Field(key: "resourceType", emit_null: false)]
    property resource_type : Cdp::Network::ResourceType?
    @[JSON::Field(key: "requestStage", emit_null: false)]
    property request_stage : RequestStage?
  end

  struct HeaderEntry
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
  end

  struct AuthChallenge
    include JSON::Serializable
    @[JSON::Field(key: "source", emit_null: false)]
    property source : AuthChallengeSource?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "scheme", emit_null: false)]
    property scheme : String
    @[JSON::Field(key: "realm", emit_null: false)]
    property realm : String
  end

  struct AuthChallengeResponse
    include JSON::Serializable
    @[JSON::Field(key: "response", emit_null: false)]
    property response : AuthChallengeResponseResponse
    @[JSON::Field(key: "username", emit_null: false)]
    property username : String?
    @[JSON::Field(key: "password", emit_null: false)]
    property password : String?
  end

  alias AuthChallengeSource = String
  AuthChallengeSourceServer = "Server"
  AuthChallengeSourceProxy  = "Proxy"

  alias AuthChallengeResponseResponse = String
  AuthChallengeResponseResponseDefault            = "Default"
  AuthChallengeResponseResponseCancelAuth         = "CancelAuth"
  AuthChallengeResponseResponseProvideCredentials = "ProvideCredentials"
end
