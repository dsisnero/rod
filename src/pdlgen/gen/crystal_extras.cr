module Pdlgen
  module Gen
    module CrystalExtras
      # Returns Crystal code for FrameState enum (bitmask) and related constants.
      def self.extra_frame_template : String
        String.build do |str|
          str << "# FrameState is the state of a Frame.\n"
          str << "@[Flags]\n"
          str << "enum FrameState : UInt16\n"
          str << "  # Frame state flags\n"
          str << "  FrameDOMContentEventFired = 1 << 15\n"
          str << "  FrameLoadEventFired       = 1 << 14\n"
          str << "  FrameAttached             = 1 << 13\n"
          str << "  FrameNavigated            = 1 << 12\n"
          str << "  FrameLoading              = 1 << 11\n"
          str << "  FrameScheduledNavigation  = 1 << 10\n"
          str << "end\n\n"
          str << "# EmptyFrameID is the \"non-existent\" frame id.\n"
          str << "EMPTY_FRAME_ID = FrameId.new(\"\")\n"
        end
      end

      # Returns Crystal code for NodeState enum (bitmask) and related constants.
      def self.extra_node_template : String
        String.build do |str|
          str << "# NodeState is the state of a DOM node.\n"
          str << "@[Flags]\n"
          str << "enum NodeState : UInt8\n"
          str << "  # Node state flags\n"
          str << "  NodeReady          = 1 << 7\n"
          str << "  NodeChildReady     = 1 << 6\n"
          str << "  NodeDescendantReady = 1 << 5\n"
          str << "  NodeAttached       = 1 << 4\n"
          str << "  NodeHasShadowRoot  = 1 << 3\n"
          str << "  NodeMutated        = 1 << 2\n"
          str << "end\n"
        end
      end

      # Returns Crystal code for Node type extensions (Attribute, AttributeValue methods).
      # Note: These methods need to be placed inside the Node struct definition,
      # not as extra content after the type.
      def self.node_methods : String
        <<-CRYSTAL
        # AttributeValue returns the named attribute for the node.
        def attribute_value(name : String) : String
          value = attribute(name)
          value || ""
        end

        # Attribute returns the named attribute for the node and if it exists.
        def attribute(name : String) : String?
          @attributes.each_slice(2) do |pair|
            if pair[0] == name
              return pair[1]
            end
          end
          nil
        end
        CRYSTAL
      end

      # Returns Crystal code for Timestamp type marshal/unmarshal methods.
      # In Crystal, Time already implements JSON::Serializable properly,
      # but we need to handle monotonic timestamps if needed.
      def self.extra_timestamp_template(t : Pdl::Type, d : Pdl::Domain) : String
        # For now, return empty string as Time serialization is handled by JSON::Serializable
        ""
      end

      # Returns module-level DOM helpers mirroring go-rod's dom package extras.
      def self.dom_module_helpers : String
        <<-CRYSTAL
        def self.quad_to_floats(quad : Quad) : Array(Float64)
          quad.as_a.map(&.as_f)
        end

        def self.each_point(quad : Quad, & : Point ->) : Nil
          arr = quad_to_floats(quad)
          size = arr.size // 2
          (0...size).each do |i|
            yield Point.new(arr[i * 2], arr[i * 2 + 1])
          end
        end

        # Center returns average point of quad vertices.
        def self.center(quad : Quad) : Point
          total_x = 0.0
          total_y = 0.0
          count = 0
          each_point(quad) do |point|
            total_x += point.x
            total_y += point.y
            count += 1
          end
          Point.new(total_x / count, total_y / count)
        end

        # Area computes polygon area using shoelace formula.
        def self.area(quad : Quad) : Float64
          arr = quad_to_floats(quad)
          n = arr.size // 2
          sum = 0.0
          (0...n).each do |i|
            x1 = arr[i * 2]
            y1 = arr[i * 2 + 1]
            x2 = arr[((i + 1) % n) * 2]
            y2 = arr[((i + 1) % n) * 2 + 1]
            sum += x1 * y2 - x2 * y1
          end
          sum.abs / 2.0
        end
        CRYSTAL
      end

      # Returns the DOM.GetContentQuads result helpers (go-rod extras).
      def self.dom_content_quads_helpers : String
        <<-CRYSTAL
        # OnePointInside returns center point of the first quad with area >= 1.
        def one_point_inside : Point?
          @quads.each do |quad|
            if Cdp::DOM.area(quad) >= 1.0
              return Cdp::DOM.center(quad)
            end
          end
          nil
        end

        # Box returns smallest axis-aligned rect covering all quads.
        def box : Rect?
          return nil if @quads.empty?

          left = Float64::MAX
          top = Float64::MAX
          right = Float64::MIN
          bottom = Float64::MIN

          @quads.each do |quad|
            Cdp::DOM.each_point(quad) do |point|
              left = point.x if point.x < left
              top = point.y if point.y < top
              right = point.x if point.x > right
              bottom = point.y if point.y > bottom
            end
          end

          Rect.from_json({
            "x"      => left,
            "y"      => top,
            "width"  => right - left,
            "height" => bottom - top,
          }.to_json)
        end
        CRYSTAL
      end

      # Returns the Input.TouchPoint helper (go-rod extras).
      def self.touch_point_helpers : String
        <<-CRYSTAL
        # MoveTo updates X and Y coordinates.
        def move_to(x : Float64, y : Float64) : Nil
          @x = x
          @y = y
        end
        CRYSTAL
      end

      # Returns the Network.Request helper that restores go-rod's PostData field.
      # Chrome dropped the plain `postData` field; the body now arrives as
      # base64-encoded `postDataEntries`.
      def self.network_request_helpers : String
        <<-CRYSTAL
        # PostData returns the request body decoded from postDataEntries.
        def post_data : String?
          entries = @post_data_entries
          return nil if entries.nil?

          body = String.build do |io|
            entries.each do |entry|
              bytes = entry.bytes
              next if bytes.nil?

              io << Base64.decode_string(bytes)
            end
          end

          body.empty? ? nil : body
        end
        CRYSTAL
      end

      # Returns module-level Network helpers mirroring go-rod's network extras.
      def self.network_module_helpers : String
        <<-CRYSTAL
        # CookiesToParams converts Cookie list to CookieParam list.
        def self.cookies_to_params(cookies : Array(Cookie)) : Array(CookieParam)
          cookies.map do |cookie|
            expires = Time.unix_ms((cookie.expires * 1000).round.to_i64).to_s("%Y-%m-%dT%H:%M:%S.%3N%:z")
            CookieParam.from_json({
              "name"         => cookie.name,
              "value"        => cookie.value,
              "url"          => nil,
              "domain"       => cookie.domain,
              "path"         => cookie.path,
              "secure"       => cookie.secure?,
              "httpOnly"     => cookie.http_only?,
              "sameSite"     => cookie.same_site,
              "expires"      => expires,
              "priority"     => cookie.priority,
              "sourceScheme" => cookie.source_scheme,
              "sourcePort"   => cookie.source_port,
              "partitionKey" => cookie.partition_key,
            }.to_json)
          end
        end

        # TimeSinceEpochToTime mirrors go proto TimeSinceEpoch.Time helper semantics.
        def self.time_since_epoch_time(t : TimeSinceEpoch) : Time
          if t.is_a?(Time)
            return t
          end

          f = t.as(Float64)
          return Time.unix(0) if f == -1.0
          Time.unix_ms((f * 1000).round.to_i64)
        end

        # TimeSinceEpochToString mirrors go proto TimeSinceEpoch.String helper semantics.
        def self.time_since_epoch_string(t : TimeSinceEpoch) : String
          time_since_epoch_time(t).to_s
        end

        # TimeSinceEpoch helper from a Time value.
        def self.time_since_epoch(value : Time) : TimeSinceEpoch
          value
        end

        # TimeSinceEpoch helper from seconds since unix epoch.
        def self.time_since_epoch(value : Float64) : TimeSinceEpoch
          value
        end

        # TimeSinceEpoch helper from seconds since unix epoch.
        def self.time_since_epoch(value : Int) : TimeSinceEpoch
          value.to_f64
        end

        # TimeSinceEpoch helper relative to current UTC time.
        def self.time_since_epoch_from_now(delta : Time::Span) : TimeSinceEpoch
          (Time.utc + delta).to_unix.to_f64
        end

        # MonotonicTimeToDuration mirrors go proto MonotonicTime.Duration semantics.
        def self.monotonic_time_duration(t : MonotonicTime) : Time::Span
          seconds = t.is_a?(Time) ? (t.to_unix_ms / 1000.0) : t.as(Float64)
          seconds.seconds
        end

        # MonotonicTimeToString mirrors go proto MonotonicTime.String semantics.
        def self.monotonic_time_string(t : MonotonicTime) : String
          monotonic_time_duration(t).to_s
        end
        CRYSTAL
      end
    end
  end
end
