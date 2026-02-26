require "./spec_helper"

describe Rod::Context do
  it "propagates parent cancellation to child context" do
    parent = Rod::Context.new
    child = Rod::Context.new(parent)

    parent.cancel
    sleep 10.milliseconds

    child.cancelled?.should be_true
    child.err.should be_a(Rod::ContextCanceledError)
  end

  it "propagates parent timeout to child context" do
    parent = Rod::Context.new
    timed, _cancel = parent.with_timeout(20.milliseconds)
    child = Rod::Context.new(timed)

    sleep 50.milliseconds

    child.cancelled?.should be_true
    child.err.should be_a(Rod::ContextTimeoutError)
  end

  it "returns timeout error when with_timeout deadline expires" do
    ctx = Rod::Context.new
    timed, _cancel = ctx.with_timeout(20.milliseconds)

    sleep 50.milliseconds

    timed.cancelled?.should be_true
    timed.err.should be_a(Rod::ContextTimeoutError)
  end

  it "returns cancel error when with_cancel is called" do
    ctx = Rod::Context.new
    child, cancel = ctx.with_cancel

    cancel.call

    child.cancelled?.should be_true
    child.err.should be_a(Rod::ContextCanceledError)
  end
end
