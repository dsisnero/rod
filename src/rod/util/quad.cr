require "../types"
require "../../cdp/dom/dom"

module Rod::Util
  # Quad helpers for working with DOM quad arrays.
  #
  # A DOM quad is a JSON array of 8 numbers: `[x1, y1, x2, y2, x3, y3, x4, y4]`.
  # The geometry lives in the generated `Cdp::DOM` helpers, which are the port of
  # go's `DOMQuad` patch methods (`lib/proto/a_patch.go:70-120`); this module only
  # adapts them to `Rod::Point`/tuples for `Element#interactable`, `#hover`,
  # `#move_mouse_out` and `#screenshot`. Keeping one implementation matters:
  # Phase 30 had to fix the same shoelace bug in both copies when they drifted.
  module Quad
    # Number of vertices in the quad.
    def self.len(quad : ::JSON::Any) : Int32
      quad.as_a.size // 2
    end

    # Iterate over each point in the quad, with its vertex index.
    def self.each(quad : ::JSON::Any, & : Rod::Point, Int32 ->) : Nil
      index = 0
      ::Cdp::DOM.each_point(quad) do |point|
        yield Rod::Point.new(point.x, point.y), index
        index += 1
      end
    end

    # Center point of the quad (average of vertices).
    def self.center(quad : ::JSON::Any) : Rod::Point
      point = ::Cdp::DOM.center(quad)
      Rod::Point.new(point.x, point.y)
    end

    # Signed polygon area, positive for a counter-clockwise winding like go's
    # `DOMQuad.Area` (`lib/proto/a_patch.go:90-100`).
    def self.area(quad : ::JSON::Any) : Float64
      ::Cdp::DOM.area(quad)
    end

    # Find the center of the first quad with area >= 1, or nil if none.
    def self.one_point_inside(quads : Array(::JSON::Any)) : Rod::Point?
      point = ::Cdp::DOM::GetContentQuadsResult.new(quads).one_point_inside
      point.try { |dom_point| Rod::Point.new(dom_point.x, dom_point.y) }
    end

    # Smallest axis-aligned rectangle covering all quads.
    # Returns `{x, y, width, height}`, or nil when there is no quad.
    def self.box(quads : Array(::JSON::Any)) : {Float64, Float64, Float64, Float64}?
      rect = ::Cdp::DOM::GetContentQuadsResult.new(quads).box
      rect.try { |dom_rect| {dom_rect.x, dom_rect.y, dom_rect.width, dom_rect.height} }
    end
  end
end
