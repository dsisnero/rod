require "./spec_helper"

describe Rod::Util::Defaults do
  it "reset restores initial baseline values" do
    Rod::Util::Defaults.parse("show,devtools,trace,slow=2s,url=ws://x,monitor=:1,lock=9999")
    Rod::Util::Defaults.reset

    Rod::Util::Defaults.show.should be_false
    Rod::Util::Defaults.devtools.should be_false
    Rod::Util::Defaults.trace.should be_false
    Rod::Util::Defaults.slow.should eq(0.seconds)
    Rod::Util::Defaults.monitor.should eq("")
    Rod::Util::Defaults.url.should eq("")
    Rod::Util::Defaults.lock_port.should eq(2978)
  end

  it "reset and parse options match Go defaults behavior" do
    Rod::Util::Defaults.reset

    Rod::Util::Defaults.parse(
      "show,devtools,trace,slow=2s,port=8080,dir=tmp," +
      "url=http://test.com,cdp,monitor,bin=/path/to/chrome," +
      "proxy=localhost:8080,lock=9981,"
    )

    Rod::Util::Defaults.show.should be_true
    Rod::Util::Defaults.devtools.should be_true
    Rod::Util::Defaults.trace.should be_true
    Rod::Util::Defaults.slow.should eq(2.seconds)
    Rod::Util::Defaults.port.should eq("8080")
    Rod::Util::Defaults.dir.should eq("tmp")
    Rod::Util::Defaults.url.should eq("http://test.com")
    Rod::Util::Defaults.monitor.should eq(":0")
    Rod::Util::Defaults.bin.should eq("/path/to/chrome")
    Rod::Util::Defaults.proxy.should eq("localhost:8080")
    Rod::Util::Defaults.lock_port.should eq(9981)

    Rod::Util::Defaults.parse("monitor=:1234")
    Rod::Util::Defaults.monitor.should eq(":1234")

    expect_raises(Exception, /unknown rod env option: a/) { Rod::Util::Defaults.parse("a") }
    expect_raises(Exception, /invalid value for \"slow\":/) { Rod::Util::Defaults.parse("slow=1") }
  end

  it "parse_flag handles -rod and --rod forms" do
    Rod::Util::Defaults.reset
    Rod::Util::Defaults.parse_flag(["-rod"])
    Rod::Util::Defaults.show.should be_false

    Rod::Util::Defaults.parse_flag(["-rod=show"])
    Rod::Util::Defaults.show.should be_true

    Rod::Util::Defaults.reset
    Rod::Util::Defaults.parse_flag(["-rod", "show"])
    Rod::Util::Defaults.show.should be_true

    Rod::Util::Defaults.reset
    Rod::Util::Defaults.parse_flag(["--rod=show"])
    Rod::Util::Defaults.show.should be_true
  end

  it "reset_with applies -rod args then explicit options override" do
    Rod::Util::Defaults.reset_with("show", ["--rod=devtools"])
    Rod::Util::Defaults.devtools.should be_true
    Rod::Util::Defaults.show.should be_true
  end

  it "reset_with ignores argv when DISABLE_ROD_FLAG is set" do
    begin
      ENV["DISABLE_ROD_FLAG"] = "1"
      Rod::Util::Defaults.reset_with("", ["--rod=show"])
      Rod::Util::Defaults.show.should be_false
    ensure
      ENV.delete("DISABLE_ROD_FLAG")
    end
  end
end
