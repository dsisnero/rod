require "json"
require "http"
require "./cdp/types"

# Compatibility helper for generated CDP code paths that build a result object
# and then call `res.from_json(...)` on that instance.
module JSON::Serializable
  def from_json(json : String) : self
    parsed = self.class.from_json(json)
    {% for ivar in @type.instance_vars %}
      @{{ivar.name}} = parsed.@{{ivar.name}}
    {% end %}
    self
  end
end

# Chrome DevTools Protocol types.
module Cdp
  # Version of cdp protocol.
  Version = "v1.3"

  TIME_FIELD_KEYS = {
    "timestamp",
    "wallTime",
    "expires",
    "expiryTime",
    "validFrom",
    "validTo",
    "creationTime",
    "lastModified",
    "eventTime",
    "accessTime",
    "finishedTime",
    "time",
    "initialVirtualTime",
    "responseTime",
    "loadTime",
    "renderTime",
    "lastInputTime",
  }

  # Chrome DevTools Protocol method type (ie, event and command names).
  alias MethodType = String

  # Error type.
  struct Error
    property code : Int32
    property message : String
    @[JSON::Field(emit_null: false)]
    property data : JSON::Any?

    def initialize(@code, @message, @data = JSON::Any.new(""))
    end

    # Error satisfies the error interface.
    def to_s : String
      data_str = begin
        raw = @data.try(&.raw)
        if raw.nil?
          ""
        elsif raw.is_a?(String)
          raw.as(String)
        else
          data = @data
          data ? data.to_json : ""
        end
      end
      "{#{code} #{message} #{data_str}}"
    end

    def is?(other : Error) : Bool
      code == other.code && message == other.message && data == other.data
    end
  end

  # ErrCtxNotFound error.
  ErrCtxNotFound = Error.new(-32000, "Cannot find context with specified id")

  # ErrSessionNotFound error.
  ErrSessionNotFound = Error.new(-32001, "Session with given id not found.")

  # ErrSearchSessionNotFound error.
  ErrSearchSessionNotFound = Error.new(-32000, "No search session with given id found")

  # ErrCtxDestroyed error.
  ErrCtxDestroyed = Error.new(-32000, "Execution context was destroyed.")

  # ErrObjNotFound error.
  ErrObjNotFound = Error.new(-32000, "Could not find object with given id")

  # ErrNodeNotFoundAtPos error.
  ErrNodeNotFoundAtPos = Error.new(-32000, "No node found at given location")

  # ErrNotAttachedToActivePage error.
  ErrNotAttachedToActivePage = Error.new(-32000, "Not attached to an active page")

  # Client interface to send the request.
  # So that this lib doesn't handle anything has side effect.
  abstract class Client
    abstract def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
  end

  # Sessionable type has a session ID for its methods.
  module Sessionable
    abstract def session_id : String?
  end

  # Contextable type has a context for its methods.
  module Contextable
    abstract def context : HTTP::Client::Context?
  end

  # Request represents a cdp.Request.Method.
  module Request
    abstract def proto_req : String
  end

  # Event represents a cdp.Event.Params.
  module Event
    abstract def proto_event : String
  end

  # GetType from method name of this package,
  # such as Cdp.get_type("Page.enable") will return the type of Cdp::Page::Enable.
  def self.get_type(method_name : String)
    case method_name
    when "Page.enable"
      Cdp::Page::Enable
    when "Browser.getVersion"
      Cdp::Browser::GetVersion
    when "Target.getTargets"
      Cdp::Target::GetTargets
    when "Runtime.evaluate"
      Cdp::Runtime::Evaluate
    else
      nil
    end
  end

  # ParseMethodName to domain and name.
  def self.parse_method_name(method : String) : Tuple(String, String)
    arr = method.split('.')
    {arr[0], arr[1]}
  end

  # PatternToReg converts URL pattern syntax to regex string.
  def self.pattern_to_reg(pattern : String) : String
    return "" if pattern.empty?

    pattern = " " + pattern
    result = String.build do |str|
      i = 0
      while i < pattern.size
        ch = pattern[i]
        if i > 0 && ch == '*' && pattern[i - 1] != '\\'
          str << ".*"
        elsif i > 0 && ch == '?' && pattern[i - 1] != '\\'
          str << '.'
        else
          str << ch
        end
        i += 1
      end
    end

    "\\A" + result.lstrip + "\\z"
  end

  # call method with request and response containers.
  def self.call(method : String, req : Request, res : JSON::Serializable?, c : Client) : Nil
    ctx = nil
    if c.is_a?(Contextable)
      ctx = c.context
    end

    session_id = nil
    if c.is_a?(Sessionable)
      session_id = c.session_id
    end

    params = transform_outgoing(JSON.parse(req.to_json))
    bin = c.call(ctx, session_id, method, params)
    if res
      parsed = JSON.parse(String.new(bin))
      res.from_json(transform_incoming(parsed).to_json)
    end
    nil
  end

  # call method and parse response directly to type T.
  def self.call(method : String, req : Request, res_class : T.class, c : Client) : T forall T
    ctx = nil
    if c.is_a?(Contextable)
      ctx = c.context
    end

    session_id = nil
    if c.is_a?(Sessionable)
      session_id = c.session_id
    end

    params = transform_outgoing(JSON.parse(req.to_json))
    bin = c.call(ctx, session_id, method, params)
    T.from_json(transform_incoming(JSON.parse(String.new(bin))).to_json)
  end

  # Normalize protocol payload values (notably timestamp fields) so they can
  # be deserialized into generated Crystal types that use Time.
  def self.normalize_incoming(node : JSON::Any) : JSON::Any
    transform_incoming(node)
  end

  private def self.transform_outgoing(node : JSON::Any, key : String? = nil) : JSON::Any
    raw = node.raw
    case raw
    when Hash
      transformed = {} of String => JSON::Any
      raw.as(Hash(String, JSON::Any)).each do |k, v|
        transformed[k] = transform_outgoing(v, k)
      end
      JSON::Any.new(transformed)
    when Array
      JSON::Any.new(raw.as(Array(JSON::Any)).map { |v| transform_outgoing(v, key) })
    when String
      if key && TIME_FIELD_KEYS.includes?(key)
        begin
          t = Time.parse_rfc3339(raw.as(String))
          return JSON::Any.new(t.to_unix.to_f64)
        rescue
        end
      end
      node
    else
      node
    end
  end

  private def self.transform_incoming(node : JSON::Any, key : String? = nil) : JSON::Any
    raw = node.raw
    case raw
    when Hash
      transformed = {} of String => JSON::Any
      raw.as(Hash(String, JSON::Any)).each do |k, v|
        transformed[k] = transform_incoming(v, k)
      end
      JSON::Any.new(transformed)
    when Array
      JSON::Any.new(raw.as(Array(JSON::Any)).map { |v| transform_incoming(v, key) })
    when Int64, Int32
      if key && TIME_FIELD_KEYS.includes?(key)
        begin
          t = Time.unix(raw.to_i64)
          return JSON::Any.new(t.to_s("%Y-%m-%dT%H:%M:%S%:z"))
        rescue ArgumentError
          # Some protocol "timestamp" fields are not unix-second times.
          return node
        end
      end
      node
    when Float64
      if key && TIME_FIELD_KEYS.includes?(key)
        begin
          seconds = raw.as(Float64)
          millis = (seconds * 1000.0).round.to_i64
          t = Time.unix_ms(millis)
          return JSON::Any.new(t.to_s("%Y-%m-%dT%H:%M:%S.%3N%:z"))
        rescue ArgumentError
          # Preserve non-unix/large numeric timestamps for fields that are raw counters.
          return node
        end
      end
      node
    else
      node
    end
  end
end
