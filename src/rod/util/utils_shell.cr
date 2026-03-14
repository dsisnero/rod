module Rod::Util::Utils
  # Shell returns the login shell command for the current platform.
  # Ported from vendor/rod/lib/utils/shell/shell.go.
  def self.shell : String
    {% if flag?(:linux) || flag?(:openbsd) || flag?(:freebsd) %}
      nix_shell
    {% elsif flag?(:android) %}
      android_shell
    {% elsif flag?(:darwin) %}
      darwin_shell
    {% elsif flag?(:win32) %}
      windows_shell
    {% else %}
      raise "undefined GOOS"
    {% end %}
  end

  private def self.nix_shell : String
    stdout_buffer = IO::Memory.new
    status = Process.run("getent", args: ["passwd", Process.uid.to_s], output: stdout_buffer)
    raise "getent passwd failed" unless status.success?

    entry = stdout_buffer.to_s.rstrip("\n").split(":")
    raise "invalid getent output" unless entry.size >= 7
    entry[6]
  end

  private def self.android_shell : String
    shell = ENV["SHELL"]?
    raise "shell not defined in android" if shell.nil? || shell.empty?
    shell
  end

  private def self.darwin_shell : String
    user = ENV["USER"]? || ""
    dir = "Local/Default/Users/#{user}"

    stdout_buffer = IO::Memory.new
    status = Process.run("dscl", args: ["localhost", "-read", dir, "UserShell"], output: stdout_buffer)
    raise "dscl read UserShell failed" unless status.success?

    output = stdout_buffer.to_s
    matched = /UserShell: (\/[^ ]+)\n/.match(output)
    raise "invalid output: #{output}" unless matched

    shell = matched[1]
    raise "invalid output: #{output}" if shell.empty?
    shell
  end

  private def self.windows_shell : String
    ENV["COMSPEC"]? || "cmd.exe"
  end
end
