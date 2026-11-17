require "../cdp"
require "json"
require "base64"
require "time"

require "../network/network"

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
    @[JSON::Field(key: "protocol", emit_null: false)]
    property protocol : String
    @[JSON::Field(key: "keyExchange", emit_null: false)]
    property key_exchange : String
    @[JSON::Field(key: "keyExchangeGroup", emit_null: false)]
    property key_exchange_group : String?
    @[JSON::Field(key: "cipher", emit_null: false)]
    property cipher : String
    @[JSON::Field(key: "mac", emit_null: false)]
    property mac : String?
    @[JSON::Field(key: "certificate", emit_null: false)]
    property certificate : Array(String)
    @[JSON::Field(key: "subjectName", emit_null: false)]
    property subject_name : String
    @[JSON::Field(key: "issuer", emit_null: false)]
    property issuer : String
    @[JSON::Field(key: "validFrom", emit_null: false)]
    property valid_from : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "validTo", emit_null: false)]
    property valid_to : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "certificateNetworkError", emit_null: false)]
    property certificate_network_error : String?
    @[JSON::Field(key: "certificateHasWeakSignature", emit_null: false)]
    property? certificate_has_weak_signature : Bool
    @[JSON::Field(key: "certificateHasSha1Signature", emit_null: false)]
    property? certificate_has_sha1_signature : Bool
    @[JSON::Field(key: "modernSSL", emit_null: false)]
    property? modern_ssl : Bool
    @[JSON::Field(key: "obsoleteSslProtocol", emit_null: false)]
    property? obsolete_ssl_protocol : Bool
    @[JSON::Field(key: "obsoleteSslKeyExchange", emit_null: false)]
    property? obsolete_ssl_key_exchange : Bool
    @[JSON::Field(key: "obsoleteSslCipher", emit_null: false)]
    property? obsolete_ssl_cipher : Bool
    @[JSON::Field(key: "obsoleteSslSignature", emit_null: false)]
    property? obsolete_ssl_signature : Bool

    def initialize(@protocol : String, @key_exchange : String, @cipher : String, @certificate : Array(String), @subject_name : String, @issuer : String, @valid_from : Cdp::Network::TimeSinceEpoch, @valid_to : Cdp::Network::TimeSinceEpoch, @certificate_has_weak_signature : Bool, @certificate_has_sha1_signature : Bool, @modern_ssl : Bool, @obsolete_ssl_protocol : Bool, @obsolete_ssl_key_exchange : Bool, @obsolete_ssl_cipher : Bool, @obsolete_ssl_signature : Bool, @key_exchange_group : String? = nil, @mac : String? = nil, @certificate_network_error : String? = nil)
    end
  end

  @[Experimental]
  alias SafetyTipStatus = String
  SafetyTipStatusBadReputation = "badReputation"
  SafetyTipStatusLookalike     = "lookalike"

  @[Experimental]
  struct SafetyTipInfo
    include JSON::Serializable
    @[JSON::Field(key: "safetyTipStatus", emit_null: false)]
    property safety_tip_status : SafetyTipStatus
    @[JSON::Field(key: "safeUrl", emit_null: false)]
    property safe_url : String?

    def initialize(@safety_tip_status : SafetyTipStatus, @safe_url : String? = nil)
    end
  end

  @[Experimental]
  struct VisibleSecurityState
    include JSON::Serializable
    @[JSON::Field(key: "securityState", emit_null: false)]
    property security_state : SecurityState
    @[JSON::Field(key: "certificateSecurityState", emit_null: false)]
    property certificate_security_state : CertificateSecurityState?
    @[JSON::Field(key: "safetyTipInfo", emit_null: false)]
    property safety_tip_info : SafetyTipInfo?
    @[JSON::Field(key: "securityStateIssueIds", emit_null: false)]
    property security_state_issue_ids : Array(String)

    def initialize(@security_state : SecurityState, @security_state_issue_ids : Array(String), @certificate_security_state : CertificateSecurityState? = nil, @safety_tip_info : SafetyTipInfo? = nil)
    end
  end

  struct SecurityStateExplanation
    include JSON::Serializable
    @[JSON::Field(key: "securityState", emit_null: false)]
    property security_state : SecurityState
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String
    @[JSON::Field(key: "summary", emit_null: false)]
    property summary : String
    @[JSON::Field(key: "description", emit_null: false)]
    property description : String
    @[JSON::Field(key: "mixedContentType", emit_null: false)]
    property mixed_content_type : MixedContentType
    @[JSON::Field(key: "certificate", emit_null: false)]
    property certificate : Array(String)
    @[JSON::Field(key: "recommendations", emit_null: false)]
    property recommendations : Array(String)?

    def initialize(@security_state : SecurityState, @title : String, @summary : String, @description : String, @mixed_content_type : MixedContentType, @certificate : Array(String), @recommendations : Array(String)? = nil)
    end
  end

  @[Deprecated]
  struct InsecureContentStatus
    include JSON::Serializable
    @[JSON::Field(key: "ranMixedContent", emit_null: false)]
    property? ran_mixed_content : Bool
    @[JSON::Field(key: "displayedMixedContent", emit_null: false)]
    property? displayed_mixed_content : Bool
    @[JSON::Field(key: "containedMixedForm", emit_null: false)]
    property? contained_mixed_form : Bool
    @[JSON::Field(key: "ranContentWithCertErrors", emit_null: false)]
    property? ran_content_with_cert_errors : Bool
    @[JSON::Field(key: "displayedContentWithCertErrors", emit_null: false)]
    property? displayed_content_with_cert_errors : Bool
    @[JSON::Field(key: "ranInsecureContentStyle", emit_null: false)]
    property ran_insecure_content_style : SecurityState
    @[JSON::Field(key: "displayedInsecureContentStyle", emit_null: false)]
    property displayed_insecure_content_style : SecurityState

    def initialize(@ran_mixed_content : Bool, @displayed_mixed_content : Bool, @contained_mixed_form : Bool, @ran_content_with_cert_errors : Bool, @displayed_content_with_cert_errors : Bool, @ran_insecure_content_style : SecurityState, @displayed_insecure_content_style : SecurityState)
    end
  end

  alias CertificateErrorAction = String
  CertificateErrorActionContinue = "continue"
  CertificateErrorActionCancel   = "cancel"
end
