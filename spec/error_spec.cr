require "spec"
require "../src/rod"

describe Rod::TryError do
  it "initializes with value and stack" do
    err = Rod::TryError.new("test value", "stack trace")
    err.message.as(String).should contain("error value: test value")
    err.message.as(String).should contain("stack trace")
    err.value.should eq("test value")
    err.stack.should eq("stack trace")
  end

  it "is? returns true for TryError" do
    err = Rod::TryError.new("test")
    err.is?(Rod::TryError).should be_true
    err.is?(Rod::RodError).should be_false
  end

  it "unwrap returns Exception with value" do
    err = Rod::TryError.new("test")
    unwrapped = err.unwrap
    unwrapped.should be_a(Exception)
    unwrapped.message.should eq("test")
  end
end

describe Rod::ExpectElementError do
  it "initializes with remote object" do
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    err = Rod::ExpectElementError.new(remote_obj)
    err.message.as(String).should contain("expect js to return an element")
    err.message.as(String).should contain(remote_obj.to_json)
    err.remote_object.should eq(remote_obj)
  end

  it "is? returns true for ExpectElementError" do
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    err = Rod::ExpectElementError.new(remote_obj)
    err.is?(Rod::ExpectElementError).should be_true
    err.is?(Rod::ExpectElementsError).should be_false
  end
end

describe Rod::ExpectElementsError do
  it "initializes with remote object" do
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    err = Rod::ExpectElementsError.new(remote_obj)
    err.message.as(String).should contain("expect js to return an array of elements")
    err.message.as(String).should contain(remote_obj.to_json)
    err.remote_object.should eq(remote_obj)
  end

  it "is? returns true for ExpectElementsError" do
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    err = Rod::ExpectElementsError.new(remote_obj)
    err.is?(Rod::ExpectElementsError).should be_true
    err.is?(Rod::ExpectElementError).should be_false
  end
end

describe Rod::ElementNotFoundError do
  it "initializes with default message" do
    err = Rod::ElementNotFoundError.new
    err.message.as(String).should eq("cannot find element")
  end

  it "is? returns true for ElementNotFoundError" do
    err = Rod::ElementNotFoundError.new
    err.is?(Rod::ElementNotFoundError).should be_true
    err.is?(Rod::NotFoundError).should be_false
  end
end

describe Rod::ObjectNotFoundError do
  it "initializes with remote object" do
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    err = Rod::ObjectNotFoundError.new(remote_obj)
    err.message.as(String).should contain("cannot find object")
    err.message.as(String).should contain(remote_obj.to_json)
    err.remote_object.should eq(remote_obj)
  end

  it "is? returns true for ObjectNotFoundError" do
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    err = Rod::ObjectNotFoundError.new(remote_obj)
    err.is?(Rod::ObjectNotFoundError).should be_true
    err.is?(Rod::ElementNotFoundError).should be_false
  end
end

describe Rod::EvalError do
  it "initializes with exception details" do
    details = Cdp::Runtime::ExceptionDetails.from_json(%({
      "exceptionId": 1,
      "text": "Error",
      "lineNumber": 10,
      "columnNumber": 5,
      "exception": {"type": "string", "description": "Error", "value": "test error"}
    }))
    err = Rod::EvalError.new(details)
    err.message.as(String).should contain("eval js error:")
    err.exception_details.should eq(details)
  end

  it "is? returns true for EvalError" do
    details = Cdp::Runtime::ExceptionDetails.from_json(%({
      "exceptionId": 1,
      "text": "Error",
      "lineNumber": 10,
      "columnNumber": 5,
      "exception": {"type": "string"}
    }))
    err = Rod::EvalError.new(details)
    err.is?(Rod::EvalError).should be_true
    err.is?(Rod::NavigationError).should be_false
  end
end

describe Rod::NavigationError do
  it "initializes with reason" do
    err = Rod::NavigationError.new("timeout")
    err.message.as(String).should eq("navigation failed: timeout")
    err.reason.should eq("timeout")
  end

  it "is? returns true for NavigationError" do
    err = Rod::NavigationError.new("test")
    err.is?(Rod::NavigationError).should be_true
    err.is?(Rod::EvalError).should be_false
  end
end

describe Rod::PageCloseCanceledError do
  it "initializes with default message" do
    err = Rod::PageCloseCanceledError.new
    err.message.as(String).should eq("page close canceled")
  end
end

describe Rod::NotInteractableError do
  it "initializes with default message" do
    err = Rod::NotInteractableError.new
    err.message.as(String).should eq("element is not cursor interactable")
  end
end

describe Rod::InvisibleShapeError do
  pending
  it "initializes with element" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::InvisibleShapeError.new(element)
    err.message.as(String).should contain("element has no visible shape or outside the viewport")
    err.element.should eq(element)
  end

  it "unwrap returns NotInteractableError" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::InvisibleShapeError.new(element)
    unwrapped = err.unwrap
    unwrapped.should be_a(Rod::NotInteractableError)
  end

  it "is? returns true for InvisibleShapeError" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::InvisibleShapeError.new(element)
    err.is?(Rod::InvisibleShapeError).should be_true
    err.is?(Rod::CoveredError).should be_false
  end
end

describe Rod::CoveredError do
  pending
  it "initializes with element" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::CoveredError.new(element)
    err.message.as(String).should contain("element covered by")
    err.element.should eq(element)
  end

  it "unwrap returns NotInteractableError" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::CoveredError.new(element)
    unwrapped = err.unwrap
    unwrapped.should be_a(Rod::NotInteractableError)
  end
end

describe Rod::NoPointerEventsError do
  pending
  it "initializes with element" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::NoPointerEventsError.new(element)
    err.message.as(String).should contain("element's pointer-events is none")
    err.element.should eq(element)
  end

  it "unwrap returns NotInteractableError" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::NoPointerEventsError.new(element)
    unwrapped = err.unwrap
    unwrapped.should be_a(Rod::NotInteractableError)
  end
end

describe Rod::PageNotFoundError do
  it "initializes with default message" do
    err = Rod::PageNotFoundError.new
    err.message.as(String).should eq("cannot find page")
  end
end

describe Rod::NoShadowRootError do
  pending
  it "initializes with element" do
    page = Rod::Page.new(nil)
    remote_obj = Cdp::Runtime::RemoteObject.from_json(%({"type": "string"}))
    element = Rod::Element.new(remote_obj, page)
    err = Rod::NoShadowRootError.new(element)
    err.message.as(String).should contain("element has no shadow root")
    err.element.should eq(element)
  end
end

describe "Rod.is?" do
  it "returns true for exact type match" do
    err = Rod::ElementNotFoundError.new
    Rod.is?(err, Rod::ElementNotFoundError).should be_true
  end

  it "returns false for different type" do
    err = Rod::ElementNotFoundError.new
    Rod.is?(err, Rod::NotFoundError).should be_false
  end

  it "returns true for wrapped error" do
    inner = Rod::ElementNotFoundError.new
    outer = Rod::NavigationError.new("test")
    outer.cause = inner
    Rod.is?(outer, Rod::ElementNotFoundError).should be_true
  end

  it "returns false when no match" do
    inner = Rod::ElementNotFoundError.new
    outer = Rod::NavigationError.new("test")
    outer.cause = inner
    Rod.is?(outer, Rod::PageNotFoundError).should be_false
  end
end
