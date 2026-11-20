require "./spec_helper"

# go-rod's launcher shutdown (`lib/launcher/launcher.go:544-566`):
#
#   func (l *Launcher) Kill() {
#       utils.Sleep(1)
#       if l.PID() == 0 { return }
#       killGroup(l.PID())          // syscall.Kill(-pid, SIGKILL)
#       p, err := os.FindProcess(l.PID())
#       if err == nil { _ = p.Kill() }   // SIGKILL to the pid
#   }
#
#   func (l *Launcher) Cleanup() {
#       <-l.exit
#       _ = os.RemoveAll(l.Get(flags.UserDataDir))
#   }
#
# So `Kill` sends SIGKILL only (never SIGTERM) and `Cleanup` always removes the
# profile — `--rod-keep-user-data-dir` is the Manager's concern
# (`manager.go:200-208`), not the launcher's.

private class PidLauncher < Rod::Util::Launcher::Launcher
  def track_pid(pid : Int32) : Nil
    @pid = pid
  end
end

private class RecordingLauncher < PidLauncher
  property sent = [] of Tuple(Signal, Int32)

  private def signal(sig : Signal, pid : Int32) : Nil
    @sent << {sig, pid}
  end
end

describe "launcher shutdown parity" do
  it "kills with SIGKILL only, like go's killGroup + p.Kill" do
    launcher = RecordingLauncher.new
    launcher.track_pid(4242)

    launcher.kill

    {% if flag?(:unix) %}
      # go sends SIGKILL to the process group and then to the pid itself.
      launcher.sent.should eq([{Signal::KILL, -4242}, {Signal::KILL, 4242}])
    {% else %}
      launcher.sent.should eq([{Signal::KILL, 4242}])
    {% end %}
  end

  it "does not signal anything without a pid" do
    launcher = RecordingLauncher.new

    launcher.kill

    launcher.sent.should be_empty
  end

  it "kills a real process like go's killGroup + p.Kill" do
    launcher = PidLauncher.new
    process = Process.new("/bin/sh", ["-c", "while true; do sleep 0.05; done"])

    begin
      launcher.track_pid(process.pid.to_i32)
      launcher.kill

      deadline = Time.instant + 5.seconds
      until process.terminated?
        break if Time.instant > deadline
        sleep 50.milliseconds
      end
      process.terminated?.should be_true
    ensure
      unless process.terminated?
        begin
          Process.signal(Signal::KILL, process.pid.to_i32)
        rescue
        end
      end
    end
  end

  it "removes the user-data dir even with --rod-keep-user-data-dir, like go's Launcher.Cleanup" do
    dir = File.join(Dir.tempdir, "rod-launcher-cleanup-#{Random::Secure.hex(4)}")
    Dir.mkdir_p(dir)
    File.write(File.join(dir, "Preferences"), "{}")

    launcher = Rod::Util::Launcher.new
    launcher.user_data_dir(dir).set(Rod::Util::Launcher::Flags::KEEP_USER_DATA_DIR)
    launcher.cleanup

    # go's `Launcher.Cleanup` removes the profile unconditionally; only
    # `Manager.cleanup` honours the keep flag.
    Dir.exists?(dir).should be_false
  ensure
    FileUtils.rm_rf(dir) if dir
  end
end
