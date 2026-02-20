require "../fedcm/fedcm"
require "json"
require "time"

module Cdp::FedCm
  alias LoginState = String

  alias DialogType = String

  alias DialogButton = String

  alias AccountUrlType = String

  struct Account
    include JSON::Serializable

    property account_id : String
    property email : String
    property name : String
    property given_name : String
    property picture_url : String
    property idp_config_url : String
    property idp_login_url : String
    property login_state : LoginState
    @[JSON::Field(emit_null: false)]
    property terms_of_service_url : String?
    @[JSON::Field(emit_null: false)]
    property privacy_policy_url : String?
  end
end
