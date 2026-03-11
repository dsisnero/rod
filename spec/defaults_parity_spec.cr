require "./spec_helper"

describe Rod::Lib::Defaults do
  it "reset restores initial baseline values" do
    Rod::Lib::Defaults.parse("show,devtools,trace,slow=2s,url=ws://x,monitor=:1,lock=9999")
    Rod::Lib::Defaults.reset

    Rod::Lib::Defaults.show.should be_false
    Rod::Lib::Defaults.devtools.should be_false
    Rod::Lib::Defaults.trace.should be_false
    Rod::Lib::Defaults.slow.should eq(0.seconds)
    Rod::Lib::Defaults.monitor.should eq("")
    Rod::Lib::Defaults.url.should eq("")
    Rod::Lib::Defaults.lock_port.should eq(2978)
  end

  it "reset and parse options match Go defaults behavior" do
    Rod::Lib::Defaults.reset

    Rod::Lib::Defaults.parse(
      "show,devtools,trace,slow=2s,port=8080,dir=tmp," +
      "url=http://test.com,cdp,monitor,bin=/path/to/chrome," +
      "proxy=localhost:8080,lock=9981,"
    )

    Rod::Lib::Defaults.show.should be_true
    Rod::Lib::Defaults.devtools.should be_true
    Rod::Lib::Defaults.trace.should be_true
    Rod::Lib::Defaults.slow.should eq(2.seconds)
    Rod::Lib::Defaults.port.should eq("8080")
    Rod::Lib::Defaults.dir.should eq("tmp")
    Rod::Lib::Defaults.url.should eq("http://test.com")
    Rod::Lib::Defaults.monitor.should eq(":0")
    Rod::Lib::Defaults.bin.should eq("/path/to/chrome")
    Rod::Lib::Defaults.proxy.should eq("localhost:8080")
    Rod::Lib::Defaults.lock_port.should eq(9981)

    Rod::Lib::Defaults.parse("monitor=:1234")
    Rod::Lib::Defaults.monitor.should eq(":1234")

    expect_raises(Exception, /unknown rod env option: a/) { Rod::Lib::Defaults.parse("a") }
    expect_raises(Exception, /invalid value for \"slow\":/) { Rod::Lib::Defaults.parse("slow=1") }
  end

  it "parse_flag handles -rod and --rod forms" do
    Rod::Lib::Defaults.reset
    Rod::Lib::Defaults.parse_flag(["-rod"])
    Rod::Lib::Defaults.show.should be_false

    Rod::Lib::Defaults.parse_flag(["-rod=show"])
    Rod::Lib::Defaults.show.should be_true

    Rod::Lib::Defaults.reset
    Rod::Lib::Defaults.parse_flag(["-rod", "show"])
    Rod::Lib::Defaults.show.should be_true

    Rod::Lib::Defaults.reset
    Rod::Lib::Defaults.parse_flag(["--rod=show"])
    Rod::Lib::Defaults.show.should be_true
  end

  it "reset_with applies -rod args then explicit options override" do
    Rod::Lib::Defaults.reset_with("show", ["--rod=devtools"])
    Rod::Lib::Defaults.devtools.should be_true
    Rod::Lib::Defaults.show.should be_true
  end

  it "reset_with ignores argv when DISABLE_ROD_FLAG is set" do
    begin
      ENV["DISABLE_ROD_FLAG"] = "1"
      Rod::Lib::Defaults.reset_with("", ["--rod=show"])
      Rod::Lib::Defaults.show.should be_false
    ensure
      ENV.delete("DISABLE_ROD_FLAG")
    end
  end
end
