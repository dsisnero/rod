require "./spec_helper"

describe "utils misc parity" do
  it "log, logger_quiet and multi_logger mirror go utils behavior" do
    seen = [] of String
    logger = Rod::Util::Utils.log { |msg| seen << msg[0] }

    logger.println("ok")
    Rod::Util::Utils.logger_quiet.println("ignored")
    Rod::Util::Utils.multi_logger(logger, logger).println("ok")

    seen.should eq(["ok", "ok", "ok"])
  end

  it "rand_string returns requested length and is non-empty for positive length" do
    s = Rod::Util::Utils.rand_string(10)
    s.size.should eq(20)
    s.should_not be_empty
    s.should match(/\A[0-9a-f]+\z/)
  end

  it "absolute_paths expands relative paths" do
    abs = Rod::Util::Utils.absolute_paths(["src/rod.cr"])
    abs.size.should eq(1)
    abs[0].should contain("/src/rod.cr")
    Path[abs[0]].absolute?.should be_true
  end

  it "e helper is no-op for nil and raises for errors" do
    Rod::Util::Utils.e(nil)

    expect_raises(Exception, /err/) do
      Rod::Util::Utils.e(Exception.new("err"))
    end
  end

  it "retry returns fn error when fn signals stop" do
    ctx = Rod::Context.new
    sleeper = Rod::Util::Utils.count_sleeper(5)

    err = Rod::Util::Utils.retry(ctx, sleeper) do
      {true, Exception.new("stop")}
    end

    err.should_not be_nil
    err.not_nil!.message.should eq("stop")
  end

  it "default_backoff scales interval near 2x" do
    interval = 100.milliseconds
    out = Rod::Util::Utils.default_backoff(interval)

    out.should be >= 190.milliseconds
    out.should be < 210.milliseconds
  end

  it "use_node prepends resolved bin path to PATH" do
    old_path = ENV["PATH"]?
    begin
      Rod::Util::Utils.use_node_resolver_for_test(->(_std : Bool) { "/tmp/node-v20/bin" })
      ENV["PATH"] = "/usr/bin"

      Rod::Util::Utils.use_node(false)
      ENV["PATH"]?.should_not be_nil
      ENV["PATH"].not_nil!.starts_with?("/tmp/node-v20/bin:").should be_true
    ensure
      Rod::Util::Utils.use_node_resolver_for_test(nil)
      if path = old_path
        ENV["PATH"] = path
      else
        ENV.delete("PATH")
      end
    end
  end
end
