require "../cdp"
require "json"
require "time"

module Cdp::FedCm
  alias LoginState = String
  LoginStateSignIn = "SignIn"
  LoginStateSignUp = "SignUp"

  alias DialogType = String
  DialogTypeAccountChooser  = "AccountChooser"
  DialogTypeAutoReauthn     = "AutoReauthn"
  DialogTypeConfirmIdpLogin = "ConfirmIdpLogin"
  DialogTypeError           = "Error"

  alias DialogButton = String
  DialogButtonConfirmIdpLoginContinue = "ConfirmIdpLoginContinue"
  DialogButtonErrorGotIt              = "ErrorGotIt"
  DialogButtonErrorMoreDetails        = "ErrorMoreDetails"

  alias AccountUrlType = String
  AccountUrlTypeTermsOfService = "TermsOfService"
  AccountUrlTypePrivacyPolicy  = "PrivacyPolicy"

  struct Account
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property account_id : String
    @[JSON::Field(emit_null: false)]
    property email : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property given_name : String
    @[JSON::Field(emit_null: false)]
    property picture_url : String
    @[JSON::Field(emit_null: false)]
    property idp_config_url : String
    @[JSON::Field(emit_null: false)]
    property idp_login_url : String
    @[JSON::Field(emit_null: false)]
    property login_state : LoginState
    @[JSON::Field(emit_null: false)]
    property terms_of_service_url : String?
    @[JSON::Field(emit_null: false)]
    property privacy_policy_url : String?
  end
end
