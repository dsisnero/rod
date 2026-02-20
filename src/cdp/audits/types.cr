require "../audits/audits"
require "json"
require "time"
require "../network/network"

module Cdp::Audits
  struct AffectedCookie
    include JSON::Serializable

    property name : String
    property path : String
    property domain : String
  end

  struct AffectedRequest
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::Network::RequestId?
    property url : String
  end

  struct AffectedFrame
    include JSON::Serializable

    property frame_id : Cdp::Page::FrameId
  end

  alias CookieExclusionReason = String

  alias CookieWarningReason = String

  alias CookieOperation = String

  alias InsightType = String

  struct CookieIssueInsight
    include JSON::Serializable

    property type : InsightType
    @[JSON::Field(emit_null: false)]
    property table_entry_url : String?
  end

  struct CookieIssueDetails
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property cookie : AffectedCookie?
    @[JSON::Field(emit_null: false)]
    property raw_cookie_line : String?
    property cookie_warning_reasons : Array(CookieWarningReason)
    property cookie_exclusion_reasons : Array(CookieExclusionReason)
    property operation : CookieOperation
    @[JSON::Field(emit_null: false)]
    property site_for_cookies : String?
    @[JSON::Field(emit_null: false)]
    property cookie_url : String?
    @[JSON::Field(emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(emit_null: false)]
    property insight : CookieIssueInsight?
  end

  alias PerformanceIssueType = String

  struct PerformanceIssueDetails
    include JSON::Serializable

    property performance_issue_type : PerformanceIssueType
    @[JSON::Field(emit_null: false)]
    property source_code_location : SourceCodeLocation?
  end

  alias MixedContentResolutionStatus = String

  alias MixedContentResourceType = String

  struct MixedContentIssueDetails
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property resource_type : MixedContentResourceType?
    property resolution_status : MixedContentResolutionStatus
    property insecure_url : String
    property main_resource_url : String
    @[JSON::Field(emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(emit_null: false)]
    property frame : AffectedFrame?
  end

  alias BlockedByResponseReason = String

  struct BlockedByResponseIssueDetails
    include JSON::Serializable

    property request : AffectedRequest
    @[JSON::Field(emit_null: false)]
    property parent_frame : AffectedFrame?
    @[JSON::Field(emit_null: false)]
    property blocked_frame : AffectedFrame?
    property reason : BlockedByResponseReason
  end

  alias HeavyAdResolutionStatus = String

  alias HeavyAdReason = String

  struct HeavyAdIssueDetails
    include JSON::Serializable

    property resolution : HeavyAdResolutionStatus
    property reason : HeavyAdReason
    property frame : AffectedFrame
  end

  alias ContentSecurityPolicyViolationType = String

  struct SourceCodeLocation
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId?
    property url : String
    property line_number : Int64
    property column_number : Int64
  end

  struct ContentSecurityPolicyIssueDetails
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property blocked_url : String?
    property violated_directive : String
    property is_report_only : Bool
    property content_security_policy_violation_type : ContentSecurityPolicyViolationType
    @[JSON::Field(emit_null: false)]
    property frame_ancestor : AffectedFrame?
    @[JSON::Field(emit_null: false)]
    property source_code_location : SourceCodeLocation?
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId?
  end

  alias SharedArrayBufferIssueType = String

  struct SharedArrayBufferIssueDetails
    include JSON::Serializable

    property source_code_location : SourceCodeLocation
    property is_warning : Bool
    property type : SharedArrayBufferIssueType
  end

  struct LowTextContrastIssueDetails
    include JSON::Serializable

    property violating_node_id : Cdp::DOM::BackendNodeId
    property violating_node_selector : String
    property contrast_ratio : Float64
    property threshold_aa : Float64
    property threshold_aaa : Float64
    property font_size : String
    property font_weight : String
  end

  struct CorsIssueDetails
    include JSON::Serializable

    property cors_error_status : Cdp::Network::CorsErrorStatus
    property is_warning : Bool
    property request : AffectedRequest
    @[JSON::Field(emit_null: false)]
    property location : SourceCodeLocation?
    @[JSON::Field(emit_null: false)]
    property initiator_origin : String?
    @[JSON::Field(emit_null: false)]
    property resource_ip_address_space : Cdp::Network::IPAddressSpace?
    @[JSON::Field(emit_null: false)]
    property client_security_state : Cdp::Network::ClientSecurityState?
  end

  alias AttributionReportingIssueType = String

  alias SharedDictionaryError = String

  alias SRIMessageSignatureError = String

  alias UnencodedDigestError = String

  alias ConnectionAllowlistError = String

  struct AttributionReportingIssueDetails
    include JSON::Serializable

    property violation_type : AttributionReportingIssueType
    @[JSON::Field(emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property invalid_parameter : String?
  end

  struct QuirksModeIssueDetails
    include JSON::Serializable

    property is_limited_quirks_mode : Bool
    property document_node_id : Cdp::DOM::BackendNodeId
    property url : String
    property frame_id : Cdp::Page::FrameId
    property loader_id : Cdp::Network::LoaderId
  end

  struct SharedDictionaryIssueDetails
    include JSON::Serializable

    property shared_dictionary_error : SharedDictionaryError
    property request : AffectedRequest
  end

  struct SRIMessageSignatureIssueDetails
    include JSON::Serializable

    property error : SRIMessageSignatureError
    property signature_base : String
    property integrity_assertions : Array(String)
    property request : AffectedRequest
  end

  struct UnencodedDigestIssueDetails
    include JSON::Serializable

    property error : UnencodedDigestError
    property request : AffectedRequest
  end

  struct ConnectionAllowlistIssueDetails
    include JSON::Serializable

    property error : ConnectionAllowlistError
    property request : AffectedRequest
  end

  alias GenericIssueErrorType = String

  struct GenericIssueDetails
    include JSON::Serializable

    property error_type : GenericIssueErrorType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property violating_node_attribute : String?
    @[JSON::Field(emit_null: false)]
    property request : AffectedRequest?
  end

  struct DeprecationIssueDetails
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property affected_frame : AffectedFrame?
    property source_code_location : SourceCodeLocation
    property type : String
  end

  struct BounceTrackingIssueDetails
    include JSON::Serializable

    property tracking_sites : Array(String)
  end

  struct CookieDeprecationMetadataIssueDetails
    include JSON::Serializable

    property allowed_sites : Array(String)
    property opt_out_percentage : Float64
    property is_opt_out_top_level : Bool
    property operation : CookieOperation
  end

  alias ClientHintIssueReason = String

  struct FederatedAuthRequestIssueDetails
    include JSON::Serializable

    property federated_auth_request_issue_reason : FederatedAuthRequestIssueReason
  end

  alias FederatedAuthRequestIssueReason = String

  struct FederatedAuthUserInfoRequestIssueDetails
    include JSON::Serializable

    property federated_auth_user_info_request_issue_reason : FederatedAuthUserInfoRequestIssueReason
  end

  alias FederatedAuthUserInfoRequestIssueReason = String

  struct ClientHintIssueDetails
    include JSON::Serializable

    property source_code_location : SourceCodeLocation
    property client_hint_issue_reason : ClientHintIssueReason
  end

  struct FailedRequestInfo
    include JSON::Serializable

    property url : String
    property failure_message : String
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::Network::RequestId?
  end

  alias PartitioningBlobURLInfo = String

  struct PartitioningBlobURLIssueDetails
    include JSON::Serializable

    property url : String
    property partitioning_blob_url_info : PartitioningBlobURLInfo
  end

  alias ElementAccessibilityIssueReason = String

  struct ElementAccessibilityIssueDetails
    include JSON::Serializable

    property node_id : Cdp::DOM::BackendNodeId
    property element_accessibility_issue_reason : ElementAccessibilityIssueReason
    property has_disallowed_attributes : Bool
  end

  alias StyleSheetLoadingIssueReason = String

  struct StylesheetLoadingIssueDetails
    include JSON::Serializable

    property source_code_location : SourceCodeLocation
    property style_sheet_loading_issue_reason : StyleSheetLoadingIssueReason
    @[JSON::Field(emit_null: false)]
    property failed_request_info : FailedRequestInfo?
  end

  alias PropertyRuleIssueReason = String

  struct PropertyRuleIssueDetails
    include JSON::Serializable

    property source_code_location : SourceCodeLocation
    property property_rule_issue_reason : PropertyRuleIssueReason
    @[JSON::Field(emit_null: false)]
    property property_value : String?
  end

  alias UserReidentificationIssueType = String

  struct UserReidentificationIssueDetails
    include JSON::Serializable

    property type : UserReidentificationIssueType
    @[JSON::Field(emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(emit_null: false)]
    property source_code_location : SourceCodeLocation?
  end

  alias PermissionElementIssueType = String

  struct PermissionElementIssueDetails
    include JSON::Serializable

    property issue_type : PermissionElementIssueType
    @[JSON::Field(emit_null: false)]
    property type : String?
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property is_warning : Bool?
    @[JSON::Field(emit_null: false)]
    property permission_name : String?
    @[JSON::Field(emit_null: false)]
    property occluder_node_info : String?
    @[JSON::Field(emit_null: false)]
    property occluder_parent_node_info : String?
    @[JSON::Field(emit_null: false)]
    property disable_reason : String?
  end

  alias InspectorIssueCode = String

  struct InspectorIssueDetails
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property cookie_issue_details : CookieIssueDetails?
    @[JSON::Field(emit_null: false)]
    property mixed_content_issue_details : MixedContentIssueDetails?
    @[JSON::Field(emit_null: false)]
    property blocked_by_response_issue_details : BlockedByResponseIssueDetails?
    @[JSON::Field(emit_null: false)]
    property heavy_ad_issue_details : HeavyAdIssueDetails?
    @[JSON::Field(emit_null: false)]
    property content_security_policy_issue_details : ContentSecurityPolicyIssueDetails?
    @[JSON::Field(emit_null: false)]
    property shared_array_buffer_issue_details : SharedArrayBufferIssueDetails?
    @[JSON::Field(emit_null: false)]
    property low_text_contrast_issue_details : LowTextContrastIssueDetails?
    @[JSON::Field(emit_null: false)]
    property cors_issue_details : CorsIssueDetails?
    @[JSON::Field(emit_null: false)]
    property attribution_reporting_issue_details : AttributionReportingIssueDetails?
    @[JSON::Field(emit_null: false)]
    property quirks_mode_issue_details : QuirksModeIssueDetails?
    @[JSON::Field(emit_null: false)]
    property partitioning_blob_url_issue_details : PartitioningBlobURLIssueDetails?
    @[JSON::Field(emit_null: false)]
    property generic_issue_details : GenericIssueDetails?
    @[JSON::Field(emit_null: false)]
    property deprecation_issue_details : DeprecationIssueDetails?
    @[JSON::Field(emit_null: false)]
    property client_hint_issue_details : ClientHintIssueDetails?
    @[JSON::Field(emit_null: false)]
    property federated_auth_request_issue_details : FederatedAuthRequestIssueDetails?
    @[JSON::Field(emit_null: false)]
    property bounce_tracking_issue_details : BounceTrackingIssueDetails?
    @[JSON::Field(emit_null: false)]
    property cookie_deprecation_metadata_issue_details : CookieDeprecationMetadataIssueDetails?
    @[JSON::Field(emit_null: false)]
    property stylesheet_loading_issue_details : StylesheetLoadingIssueDetails?
    @[JSON::Field(emit_null: false)]
    property property_rule_issue_details : PropertyRuleIssueDetails?
    @[JSON::Field(emit_null: false)]
    property federated_auth_user_info_request_issue_details : FederatedAuthUserInfoRequestIssueDetails?
    @[JSON::Field(emit_null: false)]
    property shared_dictionary_issue_details : SharedDictionaryIssueDetails?
    @[JSON::Field(emit_null: false)]
    property element_accessibility_issue_details : ElementAccessibilityIssueDetails?
    @[JSON::Field(emit_null: false)]
    property sri_message_signature_issue_details : SRIMessageSignatureIssueDetails?
    @[JSON::Field(emit_null: false)]
    property unencoded_digest_issue_details : UnencodedDigestIssueDetails?
    @[JSON::Field(emit_null: false)]
    property connection_allowlist_issue_details : ConnectionAllowlistIssueDetails?
    @[JSON::Field(emit_null: false)]
    property user_reidentification_issue_details : UserReidentificationIssueDetails?
    @[JSON::Field(emit_null: false)]
    property permission_element_issue_details : PermissionElementIssueDetails?
    @[JSON::Field(emit_null: false)]
    property performance_issue_details : PerformanceIssueDetails?
  end

  alias IssueId = String

  struct InspectorIssue
    include JSON::Serializable

    property code : InspectorIssueCode
    property details : InspectorIssueDetails
    @[JSON::Field(emit_null: false)]
    property issue_id : IssueId?
  end

  alias GetEncodedResponseEncoding = String
end
