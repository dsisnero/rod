# Port of github.com/ysmood/gson - A tiny JSON lib to read and alter a JSON value.
module Gson
  VERSION = "0.1.0"

  # JSON represents a JSON value
  class JSON
    @raw : ::JSON::Any

    # New JSON from bytes, IO, or raw value.
    def self.new(v : ::JSON::Any)
      instance = allocate
      instance.initialize(v)
      instance
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : String)
      new(::JSON.parse(v))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Bytes)
      new(String.new(v))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Nil)
      new(::JSON::Any.new(nil))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Int)
      new(::JSON::Any.new(v.to_i64))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Float)
      new(::JSON::Any.new(v.to_f64))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Bool)
      new(::JSON::Any.new(v))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Array)
      new(::JSON::Any.new(v.map { |e| ::JSON::Any.new(e) }))
    end

    # New JSON from bytes, IO, or raw value.
    def self.new(v : Hash)
      new(::JSON::Any.new(v.transform_values { |e| ::JSON::Any.new(e) }))
    end

    # New JSON from bytes, IO, or raw value (generic catch-all).
    def self.new(v)
      # Convert to JSON via to_json
      new(::JSON.parse(v.to_json))
    end

    # NewFrom json encoded string
    def self.new_from(s : String)
      new(s)
    end

    protected def initialize(@raw : ::JSON::Any)
    end

    # Raw underlying value
    def raw
      @raw.raw
    end

    # Val of the underlying json value.
    def val
      @raw
    end

    # String representation
    def to_s(io : IO)
      @raw.to_json(io)
    end

    # Marshal to JSON
    def to_json(io : IO)
      @raw.to_json(io)
    end

    # Parse from JSON
    def self.from_json(json : String)
      new(::JSON.parse(json))
    end
  end
end
