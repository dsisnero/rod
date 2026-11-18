require "./spec_helper"
require "file_utils"

# go-rod's `Launcher.Launch` waits for the DevTools URL, the process exit, or
# context cancellation — it has no launch timeout. A fixed timeout turns a slow
# cold start (loaded machine, many browsers) into a hard failure, which is what
# made the live-browser specs flaky under load.
private def fake_browser_script(dir : String, name : String, body : String) : String
  path = File.join(dir, name)
  File.write(path, "#!/bin/sh\n#{body}\n")
  File.chmod(path, 0o755)
  path
end

private DEVTOOLS_LINE = "DevTools listening on ws://127.0.0.1:65535/devtools/browser/00000000-0000-0000-0000-000000000000"

describe "launcher launch parity" do
  it "waits past ten seconds for a slow browser to print the debug url" do
    dir = File.join("temp", "launcher_slow_#{Random::Secure.hex(4)}")
    Dir.mkdir_p(dir)
    # The delay must exceed the 10s timeout the port used to impose.
    bin = fake_browser_script(dir, "chrome", "sleep 11\necho '#{DEVTOOLS_LINE}'\nsleep 5")

    launcher = Rod::Util::Launcher::Launcher.new
      .bin(bin)
      .leakless(false)

    begin
      launcher.launch.should eq(DEVTOOLS_LINE.split(' ').last)
    ensure
      shutdown_launcher(launcher)
      FileUtils.rm_rf(dir)
    end
  end

  it "raises when the browser exits before printing the debug url" do
    dir = File.join("temp", "launcher_exit_#{Random::Secure.hex(4)}")
    Dir.mkdir_p(dir)
    bin = fake_browser_script(dir, "chrome", "echo 'boom: cannot start'\nexit 1")

    launcher = Rod::Util::Launcher::Launcher.new
      .bin(bin)
      .leakless(false)

    begin
      expect_raises(Exception, /Failed to get the debug url/) { launcher.launch }
    ensure
      shutdown_launcher(launcher)
      FileUtils.rm_rf(dir)
    end
  end
end
