require "../cdp"
require "json"
require "time"

module Cdp::WebAuthn
  alias AuthenticatorId = String

  alias AuthenticatorProtocol = String
  AuthenticatorProtocolU2f   = "u2f"
  AuthenticatorProtocolCtap2 = "ctap2"

  alias Ctap2Version = String
  Ctap2VersionCtap20 = "ctap2_0"
  Ctap2VersionCtap21 = "ctap2_1"

  alias AuthenticatorTransport = String
  AuthenticatorTransportUsb      = "usb"
  AuthenticatorTransportNfc      = "nfc"
  AuthenticatorTransportBle      = "ble"
  AuthenticatorTransportCable    = "cable"
  AuthenticatorTransportInternal = "internal"

  struct VirtualAuthenticatorOptions
    include JSON::Serializable
    @[JSON::Field(key: "protocol", emit_null: false)]
    property protocol : AuthenticatorProtocol
    @[JSON::Field(key: "ctap2Version", emit_null: false)]
    property ctap2_version : Ctap2Version?
    @[JSON::Field(key: "transport", emit_null: false)]
    property transport : AuthenticatorTransport
    @[JSON::Field(key: "hasResidentKey", emit_null: false)]
    property? has_resident_key : Bool?
    @[JSON::Field(key: "hasUserVerification", emit_null: false)]
    property? has_user_verification : Bool?
    @[JSON::Field(key: "hasLargeBlob", emit_null: false)]
    property? has_large_blob : Bool?
    @[JSON::Field(key: "hasCredBlob", emit_null: false)]
    property? has_cred_blob : Bool?
    @[JSON::Field(key: "hasMinPinLength", emit_null: false)]
    property? has_min_pin_length : Bool?
    @[JSON::Field(key: "hasPrf", emit_null: false)]
    property? has_prf : Bool?
    @[JSON::Field(key: "automaticPresenceSimulation", emit_null: false)]
    property? automatic_presence_simulation : Bool?
    @[JSON::Field(key: "isUserVerified", emit_null: false)]
    property? is_user_verified : Bool?
    @[JSON::Field(key: "defaultBackupEligibility", emit_null: false)]
    property? default_backup_eligibility : Bool?
    @[JSON::Field(key: "defaultBackupState", emit_null: false)]
    property? default_backup_state : Bool?
  end

  struct Credential
    include JSON::Serializable
    @[JSON::Field(key: "credentialId", emit_null: false)]
    property credential_id : String
    @[JSON::Field(key: "isResidentCredential", emit_null: false)]
    property? is_resident_credential : Bool
    @[JSON::Field(key: "rpId", emit_null: false)]
    property rp_id : String?
    @[JSON::Field(key: "privateKey", emit_null: false)]
    property private_key : String
    @[JSON::Field(key: "userHandle", emit_null: false)]
    property user_handle : String?
    @[JSON::Field(key: "signCount", emit_null: false)]
    property sign_count : Int64
    @[JSON::Field(key: "largeBlob", emit_null: false)]
    property large_blob : String?
    @[JSON::Field(key: "backupEligibility", emit_null: false)]
    property? backup_eligibility : Bool?
    @[JSON::Field(key: "backupState", emit_null: false)]
    property? backup_state : Bool?
    @[JSON::Field(key: "userName", emit_null: false)]
    property user_name : String?
    @[JSON::Field(key: "userDisplayName", emit_null: false)]
    property user_display_name : String?
  end
end
