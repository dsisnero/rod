require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Overlay
  struct SourceOrderConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property parent_outline_color : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property child_outline_color : Cdp::NodeType
  end

  struct GridHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? show_grid_extension_lines : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_positive_line_numbers : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_negative_line_numbers : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_area_names : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_line_names : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_track_sizes : Bool?
    @[JSON::Field(emit_null: false)]
    property grid_border_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cell_border_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property row_line_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property column_line_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? grid_border_dash : Bool?
    @[JSON::Field(emit_null: false)]
    property? row_line_dash : Bool?
    @[JSON::Field(emit_null: false)]
    property? column_line_dash : Bool?
    @[JSON::Field(emit_null: false)]
    property row_gap_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property row_hatch_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property column_gap_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property column_hatch_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property area_border_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property grid_background_color : Cdp::NodeType?
  end

  struct FlexContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property container_border : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property line_separator : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property item_separator : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property main_distributed_space : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cross_distributed_space : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property row_gap_space : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property column_gap_space : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cross_alignment : Cdp::NodeType?
  end

  struct FlexItemHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property base_size_box : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property base_size_border : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property flexibility_arrow : Cdp::NodeType?
  end

  struct LineStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property pattern : Cdp::NodeType?
  end

  struct BoxStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property fill_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property hatch_color : Cdp::NodeType?
  end

  alias ContrastAlgorithm = String
  ContrastAlgorithmAa   = "aa"
  ContrastAlgorithmAaa  = "aaa"
  ContrastAlgorithmApca = "apca"

  struct HighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? show_info : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_styles : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_rulers : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_accessibility_info : Bool?
    @[JSON::Field(emit_null: false)]
    property? show_extension_lines : Bool?
    @[JSON::Field(emit_null: false)]
    property content_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property padding_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property border_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property margin_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property event_target_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property shape_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property shape_margin_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property css_grid_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property color_format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property grid_highlight_config : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property flex_container_highlight_config : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property flex_item_highlight_config : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property contrast_algorithm : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property container_query_container_highlight_config : Cdp::NodeType?
  end

  alias ColorFormat = String
  ColorFormatRgb = "rgb"
  ColorFormatHsl = "hsl"
  ColorFormatHwb = "hwb"
  ColorFormatHex = "hex"

  struct GridNodeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property grid_highlight_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
  end

  struct FlexNodeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property flex_container_highlight_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
  end

  struct ScrollSnapContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property snapport_border : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property snap_area_border : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property scroll_margin_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property scroll_padding_color : Cdp::NodeType?
  end

  struct ScrollSnapHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property scroll_snap_container_highlight_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
  end

  struct HingeConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rect : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property content_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property outline_color : Cdp::NodeType?
  end

  struct WindowControlsOverlayConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? show_css : Bool
    @[JSON::Field(emit_null: false)]
    property selected_platform : String
    @[JSON::Field(emit_null: false)]
    property theme_color : String
  end

  struct ContainerQueryHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property container_query_container_highlight_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
  end

  struct ContainerQueryContainerHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property container_border : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property descendant_border : Cdp::NodeType?
  end

  struct IsolatedElementHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property isolation_mode_highlight_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
  end

  struct IsolationModeHighlightConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property resizer_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property resizer_handle_color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property mask_color : Cdp::NodeType?
  end

  alias InspectMode = String
  InspectModeSearchForNode         = "searchForNode"
  InspectModeSearchForUAShadowDOM  = "searchForUAShadowDOM"
  InspectModeCaptureAreaScreenshot = "captureAreaScreenshot"
  InspectModeNone                  = "none"

  struct InspectedElementAnchorConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?
  end

  alias LineStylePattern = String
  LineStylePatternDashed = "dashed"
  LineStylePatternDotted = "dotted"
end
