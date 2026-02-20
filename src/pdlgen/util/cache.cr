module Pdlgen
  module Util
    # Cache holds information about a cached file.
    struct Cache
      getter url : String
      getter path : String
      getter ttl : Time::Span
      getter decode : Bool

      def initialize(@url, @path, @ttl, @decode = false)
      end
    end
  end
end
