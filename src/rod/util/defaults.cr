module Rod::Util::Defaults
  @@trace = false
  @@slow = 0.seconds
  @@monitor = ""
  @@show = false
  @@devtools = false
  @@dir = ""
  @@port = "0"
  @@bin = ""
  @@proxy = ""
  @@lock_port = 2978
  @@url = ""
  @@cdp = Rod::Util::Utils.logger_quiet

  # Default logger
  def self.logger
    @@logger ||= ::Log.for("rod")
  end

  def self.trace : Bool
    @@trace
  end

  def self.slow : Time::Span
    @@slow
  end

  def self.monitor : String
    @@monitor
  end

  def self.show : Bool
    @@show
  end

  def self.devtools : Bool
    @@devtools
  end

  def self.dir : String
    @@dir
  end

  def self.port : String
    @@port
  end

  def self.bin : String
    @@bin
  end

  def self.proxy : String
    @@proxy
  end

  def self.lock_port : Int32
    @@lock_port
  end

  def self.url : String
    @@url
  end

  def self.cdp : Rod::Util::Utils::Log
    @@cdp
  end

  # Reset all defaults to initial values.
  def self.reset : Nil
    @@trace = false
    @@slow = 0.seconds
    @@monitor = ""
    @@show = false
    @@devtools = false
    @@dir = ""
    @@port = "0"
    @@bin = ""
    @@proxy = ""
    @@lock_port = 2978
    @@url = ""
    @@cdp = Rod::Util::Utils.logger_quiet
  end

  # Reset with options and optional argv list.
  def self.reset_with(options : String, args : Array(String) = ARGV) : Nil
    reset
    parse_flag(args) unless ENV["DISABLE_ROD_FLAG"]?
    parse(options)
  end

  # Parse -rod flag from argv-style input.
  def self.parse_flag(args : Array(String)) : Nil
    opts = ""
    args.each_with_index do |arg, i|
      if (arg == "-rod" || arg == "--rod") && i + 1 < args.size
        opts = args[i + 1]
      elsif m = arg.match(/^--?rod=(.*)$/)
        opts = m[1]
      end
    end

    parse(opts)
  end

  # Parse defaults option string.
  def self.parse(options : String) : Nil
    return if options.empty?

    options.split(/[\,\r\n]/).each do |part|
      kv = part.split('=', 2)
      name = kv[0].strip
      next if name.empty?
      value = kv.size == 2 ? kv[1] : ""

      case name
      when "trace"
        @@trace = true
      when "slow"
        begin
          @@slow = parse_duration(value)
        rescue ex
          raise "invalid value for \"slow\": #{ex.message} (learn format from https://golang.org/pkg/time/#ParseDuration)"
        end
      when "monitor"
        @@monitor = value.empty? ? ":0" : value
      when "show"
        @@show = true
      when "devtools"
        @@devtools = true
      when "dir"
        @@dir = value
      when "port"
        @@port = value
      when "bin"
        @@bin = value
      when "proxy"
        @@proxy = value
      when "lock"
        parsed = value.to_i64?
        @@lock_port = parsed.to_i32 if parsed
      when "url"
        @@url = value
      when "cdp"
        @@cdp = Rod::Util::Utils.log { |_msg| }
      else
        raise "unknown rod env option: #{name}"
      end
    end
  end

  private def self.parse_duration(value : String) : Time::Span
    m = value.match(/\A([0-9]+(?:\.[0-9]+)?)(ms|s|m|h)\z/)
    raise "time: missing unit in duration \"#{value}\"" unless m

    n = m[1].to_f64
    case m[2]
    when "ms" then n.milliseconds
    when "s"  then n.seconds
    when "m"  then n.minutes
    when "h"  then n.hours
    else
      raise "time: missing unit in duration \"#{value}\""
    end
  end

  reset_with("")
end
