require "./spec_helper"

describe "utils logger parity" do
  it "log wrapper forwards println payload" do
    seen = [] of String
    logger = Rod::Util::Utils.log { |msg| seen << msg[0] }

    logger.println("ok")
    seen.should eq(["ok"])
  end

  it "logger_quiet accepts println calls" do
    Rod::Util::Utils.logger_quiet.println("anything")
  end

  it "multi_logger fan-outs to all targets" do
    seen = [] of String
    a = Rod::Util::Utils.log { |msg| seen << msg[0] }
    b = Rod::Util::Utils.log { |msg| seen << msg[0] }

    Rod::Util::Utils.multi_logger(a, b).println("ok")

    seen.should eq(["ok", "ok"])
  end
end
