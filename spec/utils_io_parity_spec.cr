require "./spec_helper"

private class BadJSONPayload
  def to_json(io : IO) : Nil
    raise "json encode failed"
  end
end

describe "utils io parity" do
  it "noop/sleep/pause/all helpers behave like Go utils" do
    Rod::Lib::Utils.noop
    Rod::Lib::Utils.sleep(0.001)

    # Pause should block forever; run in a detached fiber and assert it's still blocked.
    blocked = true
    spawn do
      Rod::Lib::Utils.pause
      blocked = false
    end
    sleep 5.milliseconds
    blocked.should be_true

    c = 0
    Rod::Lib::Utils.all(
      -> { c += 1 },
      -> { c += 1 },
      -> { c += 1 }
    ).call
    c.should eq(3)
  end

  it "mkdir/output_file/read_string support string, bytes, and io" do
    dir = File.join(Dir.tempdir, "rod-utils-#{Random::Secure.hex(4)}")
    Rod::Lib::Utils.mkdir(dir)

    p1 = File.join(dir, "s.txt")
    Rod::Lib::Utils.output_file(p1, "test")
    Rod::Lib::Utils.read_string(p1).should eq("test")

    p2 = File.join(dir, "b.txt")
    Rod::Lib::Utils.output_file(p2, "bytes".to_slice)
    Rod::Lib::Utils.read_string(p2).should eq("bytes")

    p3 = File.join(dir, "io.txt")
    Rod::Lib::Utils.output_file(p3, IO::Memory.new("stream"))
    Rod::Lib::Utils.read_string(p3).should eq("stream")
  end

  it "output_file raises when json serialization fails" do
    dir = File.join(Dir.tempdir, "rod-utils-#{Random::Secure.hex(4)}")
    p = File.join(dir, "bad.json")

    expect_raises(Exception, /json encode failed/) do
      Rod::Lib::Utils.output_file(p, BadJSONPayload.new)
    end
  end

  it "dump/must_to_json/file_exists match Go-style behavior" do
    Rod::Lib::Utils.dump("a", 10).should eq(%("a" 10))
    Rod::Lib::Utils.must_to_json({"a" => 1}).should eq(%({"a":1}))

    Rod::Lib::Utils.file_exists(".").should be_false
    Rod::Lib::Utils.file_exists("src/rod.cr").should be_true
    Rod::Lib::Utils.file_exists("does-not-exist-#{Random::Secure.hex(4)}").should be_false
  end
end
