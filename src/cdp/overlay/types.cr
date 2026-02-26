require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../runtime/runtime"

module Cdp::Overlay
  struct SourceOrderConfig
    include JSON::Serializable
    @[JSON::Field(key: "parentOutlineColor", emit_null: false)]
    property parent_outline_color : Cdp::DOM::RGBA
    @[JSON::Field(key: "childOutlineColor", emit_null: false)]
    property child_outline_color : Cdp::DOM::RGBA
  end

  struct GridHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "showGridExtensionLines", emit_null: false)]
    property? show_grid_extension_lines : Bool?
    @[JSON::Field(key: "showPositiveLineNumbers", emit_null: false)]
    property? show_positive_line_numbers : Bool?
    @[JSON::Field(key: "showNegativeLineNumbers", emit_null: false)]
    property? show_negative_line_numbers : Bool?
    @[JSON::Field(key: "showAreaNames", emit_null: false)]
    property? show_area_names : Bool?
    @[JSON::Field(key: "showLineNames", emit_null: false)]
    property? show_line_names : Bool?
    @[JSON::Field(key: "showTrackSizes", emit_null: false)]
    property? show_track_sizes : Bool?
    @[JSON::Field(key: "gridBorderColor", emit_null: false)]
    property grid_border_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "cellBorderColor", emit_null: false)]
    property cell_border_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "rowLineColor", emit_null: false)]
    property row_line_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "columnLineColor", emit_null: false)]
    property column_line_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "gridBorderDash", emit_null: false)]
    property? grid_border_dash : Bool?
    @[JSON::Field(key: "rowLineDash", emit_null: false)]
    property? row_line_dash : Bool?
    @[JSON::Field(key: "columnLineDash", emit_null: false)]
    property? column_line_dash : Bool?
    @[JSON::Field(key: "rowGapColor", emit_null: false)]
    property row_gap_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "rowHatchColor", emit_null: false)]
    property row_hatch_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "columnGapColor", emit_null: false)]
    property column_gap_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "columnHatchColor", emit_null: false)]
    property column_hatch_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "areaBorderColor", emit_null: false)]
    property area_border_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "gridBackgroundColor", emit_null: false)]
    property grid_background_color : Cdp::DOM::RGBA?
  end

  struct FlexContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "containerBorder", emit_null: false)]
    property container_border : LineStyle?
    @[JSON::Field(key: "lineSeparator", emit_null: false)]
    property line_separator : LineStyle?
    @[JSON::Field(key: "itemSeparator", emit_null: false)]
    property item_separator : LineStyle?
    @[JSON::Field(key: "mainDistributedSpace", emit_null: false)]
    property main_distributed_space : BoxStyle?
    @[JSON::Field(key: "crossDistributedSpace", emit_null: false)]
    property cross_distributed_space : BoxStyle?
    @[JSON::Field(key: "rowGapSpace", emit_null: false)]
    property row_gap_space : BoxStyle?
    @[JSON::Field(key: "columnGapSpace", emit_null: false)]
    property column_gap_space : BoxStyle?
    @[JSON::Field(key: "crossAlignment", emit_null: false)]
    property cross_alignment : LineStyle?
  end

  struct FlexItemHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "baseSizeBox", emit_null: false)]
    property base_size_box : BoxStyle?
    @[JSON::Field(key: "baseSizeBorder", emit_null: false)]
    property base_size_border : LineStyle?
    @[JSON::Field(key: "flexibilityArrow", emit_null: false)]
    property flexibility_arrow : LineStyle?
  end

  struct LineStyle
    include JSON::Serializable
    @[JSON::Field(key: "color", emit_null: false)]
    property color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "pattern", emit_null: false)]
    property pattern : LineStylePattern?
  end

  struct BoxStyle
    include JSON::Serializable
    @[JSON::Field(key: "fillColor", emit_null: false)]
    property fill_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "hatchColor", emit_null: false)]
    property hatch_color : Cdp::DOM::RGBA?
  end

  alias ContrastAlgorithm = String
  ContrastAlgorithmAa   = "aa"
  ContrastAlgorithmAaa  = "aaa"
  ContrastAlgorithmApca = "apca"

  struct HighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "showInfo", emit_null: false)]
    property? show_info : Bool?
    @[JSON::Field(key: "showStyles", emit_null: false)]
    property? show_styles : Bool?
    @[JSON::Field(key: "showRulers", emit_null: false)]
    property? show_rulers : Bool?
    @[JSON::Field(key: "showAccessibilityInfo", emit_null: false)]
    property? show_accessibility_info : Bool?
    @[JSON::Field(key: "showExtensionLines", emit_null: false)]
    property? show_extension_lines : Bool?
    @[JSON::Field(key: "contentColor", emit_null: false)]
    property content_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "paddingColor", emit_null: false)]
    property padding_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "borderColor", emit_null: false)]
    property border_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "marginColor", emit_null: false)]
    property margin_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "eventTargetColor", emit_null: false)]
    property event_target_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "shapeColor", emit_null: false)]
    property shape_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "shapeMarginColor", emit_null: false)]
    property shape_margin_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "cssGridColor", emit_null: false)]
    property css_grid_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "colorFormat", emit_null: false)]
    property color_format : ColorFormat?
    @[JSON::Field(key: "gridHighlightConfig", emit_null: false)]
    property grid_highlight_config : GridHighlightConfig?
    @[JSON::Field(key: "flexContainerHighlightConfig", emit_null: false)]
    property flex_container_highlight_config : FlexContainerHighlightConfig?
    @[JSON::Field(key: "flexItemHighlightConfig", emit_null: false)]
    property flex_item_highlight_config : FlexItemHighlightConfig?
    @[JSON::Field(key: "contrastAlgorithm", emit_null: false)]
    property contrast_algorithm : ContrastAlgorithm?
    @[JSON::Field(key: "containerQueryContainerHighlightConfig", emit_null: false)]
    property container_query_container_highlight_config : ContainerQueryContainerHighlightConfig?
  end

  alias ColorFormat = String
  ColorFormatRgb = "rgb"
  ColorFormatHsl = "hsl"
  ColorFormatHwb = "hwb"
  ColorFormatHex = "hex"

  struct GridNodeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "gridHighlightConfig", emit_null: false)]
    property grid_highlight_config : GridHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
  end

  struct FlexNodeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "flexContainerHighlightConfig", emit_null: false)]
    property flex_container_highlight_config : FlexContainerHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
  end

  struct ScrollSnapContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "snapportBorder", emit_null: false)]
    property snapport_border : LineStyle?
    @[JSON::Field(key: "snapAreaBorder", emit_null: false)]
    property snap_area_border : LineStyle?
    @[JSON::Field(key: "scrollMarginColor", emit_null: false)]
    property scroll_margin_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "scrollPaddingColor", emit_null: false)]
    property scroll_padding_color : Cdp::DOM::RGBA?
  end

  struct ScrollSnapHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "scrollSnapContainerHighlightConfig", emit_null: false)]
    property scroll_snap_container_highlight_config : ScrollSnapContainerHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
  end

  struct HingeConfig
    include JSON::Serializable
    @[JSON::Field(key: "rect", emit_null: false)]
    property rect : Cdp::DOM::Rect
    @[JSON::Field(key: "contentColor", emit_null: false)]
    property content_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "outlineColor", emit_null: false)]
    property outline_color : Cdp::DOM::RGBA?
  end

  struct WindowControlsOverlayConfig
    include JSON::Serializable
    @[JSON::Field(key: "showCss", emit_null: false)]
    property? show_css : Bool
    @[JSON::Field(key: "selectedPlatform", emit_null: false)]
    property selected_platform : String
    @[JSON::Field(key: "themeColor", emit_null: false)]
    property theme_color : String
  end

  struct ContainerQueryHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "containerQueryContainerHighlightConfig", emit_null: false)]
    property container_query_container_highlight_config : ContainerQueryContainerHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
  end

  struct ContainerQueryContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "containerBorder", emit_null: false)]
    property container_border : LineStyle?
    @[JSON::Field(key: "descendantBorder", emit_null: false)]
    property descendant_border : LineStyle?
  end

  struct IsolatedElementHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "isolationModeHighlightConfig", emit_null: false)]
    property isolation_mode_highlight_config : IsolationModeHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
  end

  struct IsolationModeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "resizerColor", emit_null: false)]
    property resizer_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "resizerHandleColor", emit_null: false)]
    property resizer_handle_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "maskColor", emit_null: false)]
    property mask_color : Cdp::DOM::RGBA?
  end

  alias InspectMode = String
  InspectModeSearchForNode         = "searchForNode"
  InspectModeSearchForUAShadowDOM  = "searchForUAShadowDOM"
  InspectModeCaptureAreaScreenshot = "captureAreaScreenshot"
  InspectModeNone                  = "none"

  struct InspectedElementAnchorConfig
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
  end

  alias LineStylePattern = String
  LineStylePatternDashed = "dashed"
  LineStylePatternDotted = "dotted"
end
