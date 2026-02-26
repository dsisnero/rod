require "json"
require "../cdp/runtime"

module Rod
  # Base error class for Rod
  class RodError < Exception
    property cause : Exception?

    # Returns true if this error is of type klass.
    def is?(klass : Exception.class) : Bool
      self.class == klass
    end
  end

  # Timeout error for wait operations
  class TimeoutError < RodError
    def initialize(message : String = "Operation timed out")
      super(message)
    end
  end

  # Element not found error
  class NotFoundError < RodError
    def initialize(message : String = "Element not found")
      super(message)
    end
  end

  # NewType pattern implementation for type-safe IDs
  # These wrapper types provide compile-time type safety while having
  # zero runtime overhead (same memory representation as underlying String)

  struct BrowserContextID
    property value : String

    def initialize(@value : String)
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def ==(other : BrowserContextID) : Bool
      @value == other.value
    end

    def_hash @value

    def to_json(json : JSON::Builder) : Nil
      json.string(@value)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_string)
    end
  end

  struct TargetID
    property value : String

    def initialize(@value : String)
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def ==(other : TargetID) : Bool
      @value == other.value
    end

    def_hash @value

    def to_json(json : JSON::Builder) : Nil
      json.string(@value)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_string)
    end
  end

  struct SessionID
    property value : String

    def initialize(@value : String)
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def ==(other : SessionID) : Bool
      @value == other.value
    end

    def_hash @value

    def to_json(json : JSON::Builder) : Nil
      json.string(@value)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_string)
    end
  end

  struct FrameID
    property value : String

    def initialize(@value : String)
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def ==(other : FrameID) : Bool
      @value == other.value
    end

    def_hash @value

    def to_json(json : JSON::Builder) : Nil
      json.string(@value)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_string)
    end
  end

  struct ExecutionContextID
    property value : Int64

    def initialize(@value : Int64)
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def ==(other : ExecutionContextID) : Bool
      @value == other.value
    end

    def_hash @value

    def to_json(json : JSON::Builder) : Nil
      json.number(@value)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_int)
    end
  end

  struct RemoteObjectID
    property value : String

    def initialize(@value : String)
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def ==(other : RemoteObjectID) : Bool
      @value == other.value
    end

    def_hash @value

    def to_json(json : JSON::Builder) : Nil
      json.string(@value)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_string)
    end
  end

  # Point from the origin (0, 0).
  struct Point
    property x : Float64
    property y : Float64

    def initialize(@x : Float64, @y : Float64)
    end

    # Add v to p and returns a new Point.
    def add(v : Point) : Point
      Point.new(x + v.x, y + v.y)
    end

    # Minus v from p and returns a new Point.
    def minus(v : Point) : Point
      Point.new(x - v.x, y - v.y)
    end

    # Scale p with s and returns a new Point.
    def scale(s : Float64) : Point
      Point.new(x * s, y * s)
    end

    def to_s(io : IO) : Nil
      io << "(#{x}, #{y})"
    end
  end

  # Pool is used to thread-safely limit the number of elements at the same time.
  class Pool(T)
    @ch : Channel(T?)
    @limit : Int32

    def initialize(limit : Int32)
      @limit = limit
      @ch = Channel(T?).new(limit)
      limit.times { @ch.send(nil) }
    end

    # Get an element from the pool. Use put to make it reusable later.
    def get(&create : -> Tuple(T?, Exception?)) : Tuple(T?, Exception?)
      elem = @ch.receive
      return {elem, nil} if elem
      create.call
    end

    # Put an element back to the pool.
    def put(elem : T?) : Nil
      @ch.send(elem)
    end

    # Cleanup elements currently stored in the pool.
    def cleanup(&iteratee : T ->) : Nil
      @limit.times do
        select
        when elem = @ch.receive?
          iteratee.call(elem) if elem
        else
        end
      end
    end
  end

  def self.new_page_pool(limit : Int32) : Pool(Page)
    Pool(Page).new(limit)
  end

  def self.new_browser_pool(limit : Int32) : Pool(Browser)
    Pool(Browser).new(limit)
  end
end
