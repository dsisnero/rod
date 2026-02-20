require "../security/security"
require "json"
require "time"

module Cdp::Security
  alias CertificateId = Int64

  alias MixedContentType = String

  alias SecurityState = String

  @[Experimental]
  struct CertificateSecurityState
    include JSON::Serializable

    property protocol : String
    property key_exchange : String
    @[JSON::Field(emit_null: false)]
    property key_exchange_group : String?
    property cipher : String
    @[JSON::Field(emit_null: false)]
    property mac : String?
    property certificate : Array(String)
    property subject_name : String
    property issuer : String
    property valid_from : Cdp::Network::TimeSinceEpoch
    property valid_to : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property certificate_network_error : String?
    property certificate_has_weak_signature : Bool
    property certificate_has_sha1_signature : Bool
    property modern_ssl : Bool
    property obsolete_ssl_protocol : Bool
    property obsolete_ssl_key_exchange : Bool
    property obsolete_ssl_cipher : Bool
    property obsolete_ssl_signature : Bool
  end

  @[Experimental]
  alias SafetyTipStatus = String

  @[Experimental]
  struct SafetyTipInfo
    include JSON::Serializable

    property safety_tip_status : SafetyTipStatus
    @[JSON::Field(emit_null: false)]
    property safe_url : String?
  end

  @[Experimental]
  struct VisibleSecurityState
    include JSON::Serializable

    property security_state : SecurityState
    @[JSON::Field(emit_null: false)]
    property certificate_security_state : CertificateSecurityState?
    @[JSON::Field(emit_null: false)]
    property safety_tip_info : SafetyTipInfo?
    property security_state_issue_ids : Array(String)
  end

  struct SecurityStateExplanation
    include JSON::Serializable

    property security_state : SecurityState
    property title : String
    property summary : String
    property description : String
    property mixed_content_type : MixedContentType
    property certificate : Array(String)
    @[JSON::Field(emit_null: false)]
    property recommendations : Array(String)?
  end

  alias CertificateErrorAction = String
end
