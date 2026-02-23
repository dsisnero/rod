require "json"
require "./types"
require "./element"
require "../cdp/runtime"

module Rod
  # TryError wraps arbitrary values and provides stack traces.
  class TryError < RodError
    property value : String
    property stack : String

    def initialize(value : String, @stack : String = "")
      @value = value
      super("error value: #{@value}\n#{@stack}")
    end

    # Returns true if err is a TryError.
    def is?(err : Exception.class) : Bool
      err == TryError
    end

    # Unwrap returns the underlying error if value is an error, otherwise
    # returns a new error with the value stringified.
    def unwrap : Exception
      # In Go, if value is an error, return it. Since we store as String,
      # we can't determine if it was originally an error.
      Exception.new(@value)
    end
  end

  # ExpectElementError is raised when JavaScript returns a non-element.
  class ExpectElementError < RodError
    property remote_object : Cdp::Runtime::RemoteObject

    def initialize(@remote_object : Cdp::Runtime::RemoteObject)
      super("expect js to return an element, but got: #{@remote_object.to_json}")
    end

    def is?(err : Exception.class) : Bool
      err == ExpectElementError
    end
  end

  # ExpectElementsError is raised when JavaScript returns a non-array of elements.
  class ExpectElementsError < RodError
    property remote_object : Cdp::Runtime::RemoteObject

    def initialize(@remote_object : Cdp::Runtime::RemoteObject)
      super("expect js to return an array of elements, but got: #{@remote_object.to_json}")
    end

    def is?(err : Exception.class) : Bool
      err == ExpectElementsError
    end
  end

  # ElementNotFoundError is raised when an element cannot be found.
  class ElementNotFoundError < RodError
    def initialize
      super("cannot find element")
    end
  end

  # NotFoundSleeper returns a sleeper that raises ElementNotFoundError on first call.
  def self.not_found_sleeper : Proc(HTTP::Client::Context?, Exception?)
    ->(_ctx : HTTP::Client::Context?) do
      ElementNotFoundError.new
    end
  end

  # ObjectNotFoundError is raised when a remote object cannot be found.
  class ObjectNotFoundError < RodError
    property remote_object : Cdp::Runtime::RemoteObject

    def initialize(@remote_object : Cdp::Runtime::RemoteObject)
      super("cannot find object: #{@remote_object.to_json}")
    end

    def is?(err : Exception.class) : Bool
      err == ObjectNotFoundError
    end
  end

  # EvalError is raised when JavaScript evaluation fails.
  class EvalError < RodError
    property exception_details : Cdp::Runtime::ExceptionDetails

    def initialize(@exception_details : Cdp::Runtime::ExceptionDetails)
      exp = @exception_details.exception
      desc = exp.description || ""
      value = exp.value || ""
      super("eval js error: #{desc} #{value}")
    end

    def is?(err : Exception.class) : Bool
      err == EvalError
    end
  end

  # NavigationError is raised when navigation fails.
  class NavigationError < RodError
    property reason : String

    def initialize(@reason : String)
      super("navigation failed: #{@reason}")
    end

    def is?(err : Exception.class) : Bool
      err == NavigationError
    end
  end

  # PageCloseCanceledError is raised when page close is canceled.
  class PageCloseCanceledError < RodError
    def initialize
      super("page close canceled")
    end
  end

  # NotInteractableError is raised when an element is not cursor interactable.
  class NotInteractableError < RodError
    def initialize
      super("element is not cursor interactable")
    end
  end

  # InvisibleShapeError is raised when an element has no visible shape or is outside viewport.
  class InvisibleShapeError < RodError
    property element : Element

    def initialize(@element : Element)
      super("element has no visible shape or outside the viewport: #{@element}")
    end

    def is?(err : Exception.class) : Bool
      err == InvisibleShapeError
    end

    # Unwrap returns the underlying NotInteractableError.
    def unwrap : Exception
      NotInteractableError.new
    end
  end

  # CoveredError is raised when an element is covered by another element.
  class CoveredError < RodError
    property element : Element

    def initialize(@element : Element)
      super("element covered by: #{@element}")
    end

    def is?(err : Exception.class) : Bool
      err == CoveredError
    end

    # Unwrap returns the underlying NotInteractableError.
    def unwrap : Exception
      NotInteractableError.new
    end
  end

  # NoPointerEventsError is raised when an element's pointer-events is none.
  class NoPointerEventsError < RodError
    property element : Element

    def initialize(@element : Element)
      super("element's pointer-events is none: #{@element}")
    end

    def is?(err : Exception.class) : Bool
      err == NoPointerEventsError
    end

    # Unwrap returns the underlying NotInteractableError.
    def unwrap : Exception
      NotInteractableError.new
    end
  end

  # PageNotFoundError is raised when a page cannot be found.
  class PageNotFoundError < RodError
    def initialize
      super("cannot find page")
    end
  end

  # NoShadowRootError is raised when an element has no shadow root.
  class NoShadowRootError < RodError
    property element : Element

    def initialize(@element : Element)
      super("element has no shadow root: #{@element}")
    end

    def is?(err : Exception.class) : Bool
      err == NoShadowRootError
    end
  end

  # Returns true if err is of type klass or wraps an error of type klass.
  def self.is?(err : Exception, klass : Exception.class) : Bool
    err.is?(klass) || (err.cause.is_a?(Exception) && Rod.is?(err.cause.as(Exception), klass))
  end
end
