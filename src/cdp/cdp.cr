require "json"
require "http"
require "./cdp/types"

# Chrome DevTools Protocol types.
module Cdp
  # Chrome DevTools Protocol method type (ie, event and command names).
  alias MethodType = String

  # Error type.
  struct Error
    property code : Int32
    property message : String

    def initialize(@code, @message)
    end

    # Error satisfies the error interface.
    def to_s : String
      "#{message} (#{code})"
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
  def self.get_type(method_name : String) : Class
    domain, name = parse_method_name(method_name)
    domain_module = Cdp.const_get(domain.camelcase).as(Module)
    # Try event name: NameEvent
    event_name = name.camelcase + "Event"
    if domain_module.const_defined?(event_name)
      return domain_module.const_get(event_name).as(Class)
    end
    # Try command name: Name
    cmd_name = name.camelcase
    if domain_module.const_defined?(cmd_name)
      return domain_module.const_get(cmd_name).as(Class)
    end
    raise "Unknown method: #{method_name}"
  rescue ex : KeyError
    raise "Unknown method: #{method_name}"
  end

  # ParseMethodName to domain and name.
  def self.parse_method_name(method : String) : Tuple(String, String)
    arr = method.split('.')
    {arr[0], arr[1]}
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

    params = req.to_json
    bin = c.call(ctx, session_id, method, JSON.parse(params))
    if res
      res.from_json(String.new(bin))
    end
    nil
  end
end
