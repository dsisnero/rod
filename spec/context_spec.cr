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

  # Go's `context.WithDeadline` keeps the parent's deadline when it is sooner:
  # `if cur, ok := parent.Deadline(); ok && cur.Before(d) { return WithCancel(parent) }`.
  # A nested timeout can therefore only shorten the budget, never extend it.
  it "caps a nested timeout at the parent's deadline" do
    ctx = Rod::Context.new
    parent, _parent_cancel = ctx.with_timeout(50.milliseconds)
    child, _child_cancel = parent.with_timeout(10.seconds)

    remaining = child.deadline_remaining
    remaining.should_not be_nil
    remaining.not_nil!.should be <= 60.milliseconds
  end

  it "keeps a timeout shorter than the parent's deadline" do
    ctx = Rod::Context.new
    parent, _parent_cancel = ctx.with_timeout(10.seconds)
    child, _child_cancel = parent.with_timeout(50.milliseconds)

    child.deadline_remaining.not_nil!.should be <= 60.milliseconds
  end

  # Go's `Context.Deadline` walks the parent chain, so a context derived with
  # `WithValue` still reports the deadline it inherited.
  it "reports the inherited deadline through a derived context" do
    ctx = Rod::Context.new
    timed, _cancel = ctx.with_timeout(50.milliseconds)
    derived = timed.with_value("key", "value")

    derived.deadline_remaining.not_nil!.should be <= 60.milliseconds
    derived.timeout_remaining(5.seconds).should be <= 60.milliseconds
    derived.deadline.should eq(timed.deadline)
  end

  it "leaves timeout remaining at the requested value without a deadline" do
    ctx = Rod::Context.new

    ctx.deadline.should be_nil
    ctx.deadline_remaining.should be_nil
    ctx.timeout_remaining(5.seconds).should eq(5.seconds)
  end
end
