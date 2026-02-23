require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Security
  alias CertificateId = Int64

  alias MixedContentType = String
  MixedContentTypeBlockable           = "blockable"
  MixedContentTypeOptionallyBlockable = "optionally-blockable"
  MixedContentTypeNone                = "none"

  alias SecurityState = String
  SecurityStateUnknown        = "unknown"
  SecurityStateNeutral        = "neutral"
  SecurityStateInsecure       = "insecure"
  SecurityStateSecure         = "secure"
  SecurityStateInfo           = "info"
  SecurityStateInsecureBroken = "insecure-broken"

  @[Experimental]
  struct CertificateSecurityState
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property protocol : String
    @[JSON::Field(emit_null: false)]
    property key_exchange : String
    @[JSON::Field(emit_null: false)]
    property key_exchange_group : String?
    @[JSON::Field(emit_null: false)]
    property cipher : String
    @[JSON::Field(emit_null: false)]
    property mac : String?
    @[JSON::Field(emit_null: false)]
    property certificate : Array(String)
    @[JSON::Field(emit_null: false)]
    property subject_name : String
    @[JSON::Field(emit_null: false)]
    property issuer : String
    @[JSON::Field(emit_null: false)]
    property valid_from : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property valid_to : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property certificate_network_error : String?
    @[JSON::Field(emit_null: false)]
    property? certificate_has_weak_signature : Bool
    @[JSON::Field(emit_null: false)]
    property? certificate_has_sha1_signature : Bool
    @[JSON::Field(emit_null: false)]
    property? modern_ssl : Bool
    @[JSON::Field(emit_null: false)]
    property? obsolete_ssl_protocol : Bool
    @[JSON::Field(emit_null: false)]
    property? obsolete_ssl_key_exchange : Bool
    @[JSON::Field(emit_null: false)]
    property? obsolete_ssl_cipher : Bool
    @[JSON::Field(emit_null: false)]
    property? obsolete_ssl_signature : Bool
  end

  @[Experimental]
  alias SafetyTipStatus = String
  SafetyTipStatusBadReputation = "badReputation"
  SafetyTipStatusLookalike     = "lookalike"

  @[Experimental]
  struct SafetyTipInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property safety_tip_status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property safe_url : String?
  end

  @[Experimental]
  struct VisibleSecurityState
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property security_state : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property certificate_security_state : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property safety_tip_info : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property security_state_issue_ids : Array(String)
  end

  struct SecurityStateExplanation
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property security_state : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property summary : String
    @[JSON::Field(emit_null: false)]
    property description : String
    @[JSON::Field(emit_null: false)]
    property mixed_content_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property certificate : Array(String)
    @[JSON::Field(emit_null: false)]
    property recommendations : Array(String)?
  end

  alias CertificateErrorAction = String
  CertificateErrorActionContinue = "continue"
  CertificateErrorActionCancel   = "cancel"
end
