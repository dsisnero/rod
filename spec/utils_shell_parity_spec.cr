require "./spec_helper"

describe Rod::Lib::Utils do
  describe ".shell" do
    {% if flag?(:linux) || flag?(:openbsd) || flag?(:freebsd) %}
      it "matches getent passwd shell entry" do
        io = IO::Memory.new
        status = Process.run("getent", args: ["passwd", Process.uid.to_s], output: io)
        status.success?.should be_true

        entry = io.to_s.rstrip("\n").split(":")
        entry.size.should be >= 7

        Rod::Lib::Utils.shell.should eq(entry[6])
      end
    {% elsif flag?(:android) %}
      it "uses SHELL environment variable" do
        shell = ENV["SHELL"]?
        shell.should_not be_nil
        shell.should_not be_empty

        Rod::Lib::Utils.shell.should eq(shell)
      end
    {% elsif flag?(:darwin) %}
      it "matches dscl UserShell output" do
        user = ENV["USER"]?
        if user.nil? || user.empty?
          expect_raises(Exception) { Rod::Lib::Utils.shell }
          next
        end

        io = IO::Memory.new
        status = Process.run(
          "dscl",
          args: ["localhost", "-read", "Local/Default/Users/#{user}", "UserShell"],
          output: io
        )
        unless status.success?
          expect_raises(Exception) { Rod::Lib::Utils.shell }
          next
        end

        matched = /UserShell: (\/[^ ]+)\n/.match(io.to_s)
        matched.should_not be_nil

        Rod::Lib::Utils.shell.should eq(matched.not_nil![1])
      end
    {% elsif flag?(:win32) %}
      it "uses COMSPEC with cmd.exe fallback" do
        expected = ENV["COMSPEC"]? || "cmd.exe"
        Rod::Lib::Utils.shell.should eq(expected)
      end
    {% end %}
  end
end
