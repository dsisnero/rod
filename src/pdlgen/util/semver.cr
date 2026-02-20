require "regex"

module Pdlgen
  module Util
    # MakeSemver makes a semver for v.
    def self.make_semver(v : String) : Semver
      # replace last . with -
      if v.count('.') > 2
        n = v.rindex('.')
        if n
          v = v[0...n] + "-" + v[n + 1..]
        end
      end
      Semver.parse(v)
    end

    # CompareSemver returns true if the semver of a is less than the semver of b.
    def self.compare_semver(a : String, b : String) : Bool
      make_semver(b) > make_semver(a)
    end

    # Simple semver implementation
    class Semver
      include Comparable(self)

      getter major : Int32
      getter minor : Int32
      getter patch : Int32
      getter prerelease : String?
      getter build : String?

      def initialize(@major, @minor, @patch, @prerelease = nil, @build = nil)
      end

      def self.parse(v : String) : Semver
        # Parse semver string like 1.2.3-alpha+build
        # Simplified: handle major.minor.patch[-prerelease][+build]
        v = v.strip
        build = nil
        prerelease = nil

        # Split on +
        if idx = v.index('+')
          build = v[idx + 1..]
          v = v[0...idx]
        end

        # Split on -
        if idx = v.index('-')
          prerelease = v[idx + 1..]
          v = v[0...idx]
        end

        parts = v.split('.')
        raise "Invalid version: #{v}" unless parts.size >= 3
        major = parts[0].to_i
        minor = parts[1].to_i
        patch = parts[2].to_i

        Semver.new(major, minor, patch, prerelease, build)
      end

      def <=>(other : Semver) : Int32
        cmp = major <=> other.major
        return cmp unless cmp == 0
        cmp = minor <=> other.minor
        return cmp unless cmp == 0
        cmp = patch <=> other.patch
        return cmp unless cmp == 0

        # Compare prerelease (nil is greater than any prerelease)
        case {prerelease, other.prerelease}
        when {nil, nil}
          0
        when {nil, _}
          1
        when {_, nil}
          -1
        else
          prerelease.not_nil! <=> other.prerelease.not_nil!
        end
      end

      def to_s : String
        str = "#{major}.#{minor}.#{patch}"
        str = "#{str}-#{prerelease}" if prerelease
        str = "#{str}+#{build}" if build
        str
      end
    end
  end
end
