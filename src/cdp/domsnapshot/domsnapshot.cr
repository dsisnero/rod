
require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../domdebugger/domdebugger"

require "./types"

# This domain facilitates obtaining document snapshots with DOM, layout, and style information.
@[Experimental]
module Cdp::DOMSnapshot
  struct CaptureSnapshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property documents : Array(DocumentSnapshot)
    @[JSON::Field(emit_null: false)]
    property strings : Array(String)

    def initialize(@documents : Array(DocumentSnapshot), @strings : Array(String))
    end
  end


  # Commands
  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMSnapshot.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMSnapshot.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CaptureSnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property computed_styles : Array(String)
    @[JSON::Field(emit_null: false)]
    property include_paint_order : Bool?
    @[JSON::Field(emit_null: false)]
    property include_dom_rects : Bool?
    @[JSON::Field(emit_null: false)]
    property include_blended_background_colors : Bool?
    @[JSON::Field(emit_null: false)]
    property include_text_color_opacities : Bool?

    def initialize(@computed_styles : Array(String), @include_paint_order : Bool?, @include_dom_rects : Bool?, @include_blended_background_colors : Bool?, @include_text_color_opacities : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMSnapshot.captureSnapshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CaptureSnapshotResult
      res = CaptureSnapshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

end
