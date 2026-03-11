require "./spec_helper"

describe Rod do
  it "returns nil when try block does not raise" do
    Rod.try { }.should be_nil
  end

  it "wraps raised exceptions in TryError with unwrap" do
    err = Rod.try do
      raise "t"
    end

    err.should be_a(Rod::TryError)
    try_err = err.as(Rod::TryError)
    try_err.unwrap.message.should eq("t")
    try_err.cause.should be_a(Exception)
    try_err.cause.as(Exception).message.should eq("t")
    try_err.to_s.should contain("error value: t")
    try_err.to_s.should contain('\n')
  end

  it "reports TryError via Rod.is?" do
    err = Rod.try do
      raise "boom"
    end

    err.should be_a(Exception)
    Rod.is?(err.as(Exception), Rod::TryError).should be_true
  end
end
