require "../types"

module Rod::Lib
  # Quad helpers for working with DOM quad arrays.
  # A DOM quad is represented as JSON::Any containing an array of 8 numbers
  # [x1, y1, x2, y2, x3, y3, x4, y4].
  module Quad
    # Convert JSON::Any quad to Array(Float64).
    private def self.to_floats(quad : ::JSON::Any) : Array(Float64)
      quad.as_a.map(&.as_f)
    end

    # Number of vertices in the quad (should be 4).
    def self.len(quad : ::JSON::Any) : Int32
      to_floats(quad).size // 2
    end

    # Iterate over each point in the quad.
    def self.each(quad : ::JSON::Any, & : Rod::Point, Int32 ->) : Nil
      arr = to_floats(quad)
      (0...len(quad)).each do |i|
        x = arr[i * 2]
        y = arr[i * 2 + 1]
        yield Rod::Point.new(x, y), i
      end
    end

    # Center point of the quad (average of vertices).
    def self.center(quad : ::JSON::Any) : Rod::Point
      total_x = 0.0
      total_y = 0.0
      each(quad) do |pt, _| # ameba:disable Naming/BlockParameterName
        total_x += pt.x
        total_y += pt.y
      end
      Rod::Point.new(total_x / len(quad), total_y / len(quad))
    end

    # Area of the polygon using shoelace formula.
    # https://en.wikipedia.org/wiki/Polygon#Area
    def self.area(quad : ::JSON::Any) : Float64
      arr = to_floats(quad)
      n = arr.size // 2 # number of vertices
      area = 0.0
      # Sum over edges (i, i+1)
      (0...n).each do |i|
        x1 = arr[i * 2]
        y1 = arr[i * 2 + 1]
        x2 = arr[(i + 1) % n * 2]
        y2 = arr[(i + 1) % n * 2 + 1]
        area += x1 * y2 - x2 * y1
      end
      area.abs / 2.0
    end

    # Find a point inside any quad with area >= 1.
    # Returns nil if no suitable quad found.
    def self.one_point_inside(quads : Array(::JSON::Any)) : Rod::Point?
      quads.each do |quad|
        if area(quad) >= 1.0
          return center(quad)
        end
      end
      nil
    end

    # Smallest axis-aligned rectangle covering all quads.
    # Returns {x, y, width, height} as a tuple.
    def self.box(quads : Array(::JSON::Any)) : {Float64, Float64, Float64, Float64}?
      return nil if quads.empty?
      min_x = Float64::MAX
      min_y = Float64::MAX
      max_x = Float64::MIN
      max_y = Float64::MIN
      quads.each do |quad|
        arr = to_floats(quad)
        (0...arr.size // 2).each do |i|
          x = arr[i * 2]
          y = arr[i * 2 + 1]
          min_x = x if x < min_x
          min_y = y if y < min_y
          max_x = x if x > max_x
          max_y = y if y > max_y
        end
      end
      {min_x, min_y, max_x - min_x, max_y - min_y}
    end
  end
end
