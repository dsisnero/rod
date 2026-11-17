require "../cdp"
require "json"
require "base64"
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

    def initialize(@parent_outline_color : Cdp::DOM::RGBA, @child_outline_color : Cdp::DOM::RGBA)
    end
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

    def initialize(@show_grid_extension_lines : Bool? = nil, @show_positive_line_numbers : Bool? = nil, @show_negative_line_numbers : Bool? = nil, @show_area_names : Bool? = nil, @show_line_names : Bool? = nil, @show_track_sizes : Bool? = nil, @grid_border_color : Cdp::DOM::RGBA? = nil, @cell_border_color : Cdp::DOM::RGBA? = nil, @row_line_color : Cdp::DOM::RGBA? = nil, @column_line_color : Cdp::DOM::RGBA? = nil, @grid_border_dash : Bool? = nil, @row_line_dash : Bool? = nil, @column_line_dash : Bool? = nil, @row_gap_color : Cdp::DOM::RGBA? = nil, @row_hatch_color : Cdp::DOM::RGBA? = nil, @column_gap_color : Cdp::DOM::RGBA? = nil, @column_hatch_color : Cdp::DOM::RGBA? = nil, @area_border_color : Cdp::DOM::RGBA? = nil, @grid_background_color : Cdp::DOM::RGBA? = nil)
    end
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

    def initialize(@container_border : LineStyle? = nil, @line_separator : LineStyle? = nil, @item_separator : LineStyle? = nil, @main_distributed_space : BoxStyle? = nil, @cross_distributed_space : BoxStyle? = nil, @row_gap_space : BoxStyle? = nil, @column_gap_space : BoxStyle? = nil, @cross_alignment : LineStyle? = nil)
    end
  end

  struct FlexItemHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "baseSizeBox", emit_null: false)]
    property base_size_box : BoxStyle?
    @[JSON::Field(key: "baseSizeBorder", emit_null: false)]
    property base_size_border : LineStyle?
    @[JSON::Field(key: "flexibilityArrow", emit_null: false)]
    property flexibility_arrow : LineStyle?

    def initialize(@base_size_box : BoxStyle? = nil, @base_size_border : LineStyle? = nil, @flexibility_arrow : LineStyle? = nil)
    end
  end

  struct LineStyle
    include JSON::Serializable
    @[JSON::Field(key: "color", emit_null: false)]
    property color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "pattern", emit_null: false)]
    property pattern : LineStylePattern?

    def initialize(@color : Cdp::DOM::RGBA? = nil, @pattern : LineStylePattern? = nil)
    end
  end

  struct BoxStyle
    include JSON::Serializable
    @[JSON::Field(key: "fillColor", emit_null: false)]
    property fill_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "hatchColor", emit_null: false)]
    property hatch_color : Cdp::DOM::RGBA?

    def initialize(@fill_color : Cdp::DOM::RGBA? = nil, @hatch_color : Cdp::DOM::RGBA? = nil)
    end
  end

  alias ContrastAlgorithm = String
  ContrastAlgorithmAa   = "aa"
  ContrastAlgorithmAaa  = "aaa"
  ContrastAlgorithmApca = "apca"

  struct ImcbHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "imcbBorderColor", emit_null: false)]
    property imcb_border_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "imcbBackgroundColor", emit_null: false)]
    property imcb_background_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "insetsBackgroundColor", emit_null: false)]
    property insets_background_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "insetsHatchColor", emit_null: false)]
    property insets_hatch_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "anchorBorderColor", emit_null: false)]
    property anchor_border_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "anchorBackgroundColor", emit_null: false)]
    property anchor_background_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "showPositionAreaGrid", emit_null: false)]
    property? show_position_area_grid : Bool?
    @[JSON::Field(key: "positionAreaGridLineColor", emit_null: false)]
    property position_area_grid_line_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "positionAreaActiveRegionColor", emit_null: false)]
    property position_area_active_region_color : Cdp::DOM::RGBA?

    def initialize(@imcb_border_color : Cdp::DOM::RGBA? = nil, @imcb_background_color : Cdp::DOM::RGBA? = nil, @insets_background_color : Cdp::DOM::RGBA? = nil, @insets_hatch_color : Cdp::DOM::RGBA? = nil, @anchor_border_color : Cdp::DOM::RGBA? = nil, @anchor_background_color : Cdp::DOM::RGBA? = nil, @show_position_area_grid : Bool? = nil, @position_area_grid_line_color : Cdp::DOM::RGBA? = nil, @position_area_active_region_color : Cdp::DOM::RGBA? = nil)
    end
  end

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
    @[JSON::Field(key: "imcbHighlightConfig", emit_null: false)]
    property imcb_highlight_config : ImcbHighlightConfig?

    def initialize(@show_info : Bool? = nil, @show_styles : Bool? = nil, @show_rulers : Bool? = nil, @show_accessibility_info : Bool? = nil, @show_extension_lines : Bool? = nil, @content_color : Cdp::DOM::RGBA? = nil, @padding_color : Cdp::DOM::RGBA? = nil, @border_color : Cdp::DOM::RGBA? = nil, @margin_color : Cdp::DOM::RGBA? = nil, @event_target_color : Cdp::DOM::RGBA? = nil, @shape_color : Cdp::DOM::RGBA? = nil, @shape_margin_color : Cdp::DOM::RGBA? = nil, @css_grid_color : Cdp::DOM::RGBA? = nil, @color_format : ColorFormat? = nil, @grid_highlight_config : GridHighlightConfig? = nil, @flex_container_highlight_config : FlexContainerHighlightConfig? = nil, @flex_item_highlight_config : FlexItemHighlightConfig? = nil, @contrast_algorithm : ContrastAlgorithm? = nil, @container_query_container_highlight_config : ContainerQueryContainerHighlightConfig? = nil, @imcb_highlight_config : ImcbHighlightConfig? = nil)
    end
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

    def initialize(@grid_highlight_config : GridHighlightConfig, @node_id : Cdp::DOM::NodeId)
    end
  end

  struct FlexNodeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "flexContainerHighlightConfig", emit_null: false)]
    property flex_container_highlight_config : FlexContainerHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId

    def initialize(@flex_container_highlight_config : FlexContainerHighlightConfig, @node_id : Cdp::DOM::NodeId)
    end
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

    def initialize(@snapport_border : LineStyle? = nil, @snap_area_border : LineStyle? = nil, @scroll_margin_color : Cdp::DOM::RGBA? = nil, @scroll_padding_color : Cdp::DOM::RGBA? = nil)
    end
  end

  struct ScrollSnapHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "scrollSnapContainerHighlightConfig", emit_null: false)]
    property scroll_snap_container_highlight_config : ScrollSnapContainerHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId

    def initialize(@scroll_snap_container_highlight_config : ScrollSnapContainerHighlightConfig, @node_id : Cdp::DOM::NodeId)
    end
  end

  struct HingeConfig
    include JSON::Serializable
    @[JSON::Field(key: "rect", emit_null: false)]
    property rect : Cdp::DOM::Rect
    @[JSON::Field(key: "contentColor", emit_null: false)]
    property content_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "outlineColor", emit_null: false)]
    property outline_color : Cdp::DOM::RGBA?

    def initialize(@rect : Cdp::DOM::Rect, @content_color : Cdp::DOM::RGBA? = nil, @outline_color : Cdp::DOM::RGBA? = nil)
    end
  end

  alias DisplayCutoutShape = String
  DisplayCutoutShapePill      = "pill"
  DisplayCutoutShapeNotch     = "notch"
  DisplayCutoutShapeCircle    = "circle"
  DisplayCutoutShapeRectangle = "rectangle"

  struct DisplayCutoutConfig
    include JSON::Serializable
    @[JSON::Field(key: "rect", emit_null: false)]
    property rect : Cdp::DOM::Rect
    @[JSON::Field(key: "shape", emit_null: false)]
    property shape : DisplayCutoutShape
    @[JSON::Field(key: "borderRadius", emit_null: false)]
    property border_radius : Int64?
    @[JSON::Field(key: "upperRadius", emit_null: false)]
    property upper_radius : Int64?
    @[JSON::Field(key: "lowerRadius", emit_null: false)]
    property lower_radius : Int64?
    @[JSON::Field(key: "cx", emit_null: false)]
    property cx : Int64?
    @[JSON::Field(key: "cy", emit_null: false)]
    property cy : Int64?
    @[JSON::Field(key: "radius", emit_null: false)]
    property radius : Int64?
    @[JSON::Field(key: "contentColor", emit_null: false)]
    property content_color : Cdp::DOM::RGBA?

    def initialize(@rect : Cdp::DOM::Rect, @shape : DisplayCutoutShape, @border_radius : Int64? = nil, @upper_radius : Int64? = nil, @lower_radius : Int64? = nil, @cx : Int64? = nil, @cy : Int64? = nil, @radius : Int64? = nil, @content_color : Cdp::DOM::RGBA? = nil)
    end
  end

  struct WindowControlsOverlayConfig
    include JSON::Serializable
    @[JSON::Field(key: "showCSS", emit_null: false)]
    property? show_css : Bool
    @[JSON::Field(key: "selectedPlatform", emit_null: false)]
    property selected_platform : String
    @[JSON::Field(key: "themeColor", emit_null: false)]
    property theme_color : String

    def initialize(@show_css : Bool, @selected_platform : String, @theme_color : String)
    end
  end

  struct ContainerQueryHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "containerQueryContainerHighlightConfig", emit_null: false)]
    property container_query_container_highlight_config : ContainerQueryContainerHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId

    def initialize(@container_query_container_highlight_config : ContainerQueryContainerHighlightConfig, @node_id : Cdp::DOM::NodeId)
    end
  end

  struct ContainerQueryContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "containerBorder", emit_null: false)]
    property container_border : LineStyle?
    @[JSON::Field(key: "descendantBorder", emit_null: false)]
    property descendant_border : LineStyle?

    def initialize(@container_border : LineStyle? = nil, @descendant_border : LineStyle? = nil)
    end
  end

  struct IsolatedElementHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "isolationModeHighlightConfig", emit_null: false)]
    property isolation_mode_highlight_config : IsolationModeHighlightConfig
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId

    def initialize(@isolation_mode_highlight_config : IsolationModeHighlightConfig, @node_id : Cdp::DOM::NodeId)
    end
  end

  struct IsolationModeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(key: "resizerColor", emit_null: false)]
    property resizer_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "resizerHandleColor", emit_null: false)]
    property resizer_handle_color : Cdp::DOM::RGBA?
    @[JSON::Field(key: "maskColor", emit_null: false)]
    property mask_color : Cdp::DOM::RGBA?

    def initialize(@resizer_color : Cdp::DOM::RGBA? = nil, @resizer_handle_color : Cdp::DOM::RGBA? = nil, @mask_color : Cdp::DOM::RGBA? = nil)
    end
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

    def initialize(@node_id : Cdp::DOM::NodeId? = nil, @backend_node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end

  alias LineStylePattern = String
  LineStylePatternDashed = "dashed"
  LineStylePatternDotted = "dotted"
end
