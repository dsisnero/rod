require "./spec_helper"

describe "utils logger parity" do
  it "log wrapper forwards println payload" do
    seen = [] of String
    logger = Rod::Lib::Utils.log { |msg| seen << msg[0] }

    logger.println("ok")
    seen.should eq(["ok"])
  end

  it "logger_quiet accepts println calls" do
    Rod::Lib::Utils.logger_quiet.println("anything")
  end

  it "multi_logger fan-outs to all targets" do
    seen = [] of String
    a = Rod::Lib::Utils.log { |msg| seen << msg[0] }
    b = Rod::Lib::Utils.log { |msg| seen << msg[0] }

    Rod::Lib::Utils.multi_logger(a, b).println("ok")

    seen.should eq(["ok", "ok"])
  end
end
