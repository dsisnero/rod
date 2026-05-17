require "base64"
require "../../cdp/io/io"
require "../../cdp/page/page"
require "crimage"
require "pluto"
require "pluto/format/jpeg"

module Rod::Util::Utils
  @@pause_ch = Channel(Nil).new
  @@reg_space = /\s/

  # Log adapter with Println compatibility.
  class Log
    def initialize(&@fn : Array(String) ->)
    end

    def println(*vs) : Nil
      @fn.call(vs.map(&.to_s).to_a)
    end

    def println(vs : Array(String)) : Nil
      @fn.call(vs)
    end
  end

  @@logger_quiet = Log.new { |_msg| }
  @@use_node_resolver : Proc(Bool, String)?

  def self.log(&block : Array(String) ->) : Log
    Log.new { |msg| block.call(msg) }
  end

  def self.logger_quiet : Log
    @@logger_quiet
  end

  # MultiLogger dispatches Println to all loggers.
  def self.multi_logger(*list : Log) : Log
    Log.new do |msg|
      list.each(&.println(msg))
    end
  end

  # Noop does nothing.
  def self.noop : Nil
  end

  # Sleep for the given number of seconds.
  def self.sleep(seconds : Float64) : Nil
    ::sleep(seconds.seconds)
  end

  # Mkdir creates a directory recursively.
  def self.mkdir(path : String) : Nil
    Dir.mkdir_p(path)
  end

  # OutputFile writes bytes/string/io/json-serialized value to file.
  def self.output_file(path : String, data) : Nil
    mkdir(File.dirname(path))

    case data
    when Bytes
      File.write(path, data)
    when String
      File.write(path, data)
    when IO
      File.open(path, "w") { |file| IO.copy(data, file) }
    else
      File.write(path, must_to_json_bytes(data))
    end
  end

  # ReadString reads a file as text.
  def self.read_string(path : String) : String
    File.read(path)
  end

  # All runs all actions concurrently and returns a wait function.
  def self.all(*actions : Proc(Nil)) : Proc(Nil)
    done = Channel(Nil).new(actions.size)
    actions.each do |action|
      spawn do
        action.call
        done.send(nil)
      end
    end

    -> do
      actions.size.times { done.receive }
    end
  end

  # Pause blocks forever.
  def self.pause : Nil
    @@pause_ch.receive
  end

  # Dump values for debugging.
  def self.dump(*list) : String
    list.map(&.to_json).join(" ")
  end

  # MustToJSONBytes encode data to json bytes.
  def self.must_to_json_bytes(data) : Bytes
    data.to_json.to_slice
  end

  # MustToJSON encode data to json string.
  def self.must_to_json(data) : String
    data.to_json
  end

  # FileExists checks if file exists and is not a directory.
  def self.file_exists(path : String) : Bool
    info = File.info?(path)
    return false unless info
    !info.directory?
  end

  # FormatCLIArgs into one line string.
  def self.format_cli_args(args : Array(String)) : String
    args.map { |arg| @@reg_space.matches?(arg) ? arg.inspect : arg }.join(" ")
  end

  # EscapeGoString formats string literal fragments in Go raw-string style.
  def self.escape_go_string(s : String) : String
    "`" + s.gsub("`", "` + \"`\" + `") + "`"
  end

  # use_node_resolver_for_test overrides use_node command output in specs.
  def self.use_node_resolver_for_test(resolver : Proc(Bool, String)?) : Nil
    @@use_node_resolver = resolver
  end

  # S template render with key-value params.
  def self.s(tpl : String, *params) : String
    values = {} of String => JSON::Any
    funcs = {} of String => Proc(String)

    i = 0
    while i + 1 < params.size
      key = params[i].to_s
      value = params[i + 1]

      case value
      when Proc(String)
        fn = value.as(Proc(String))
        funcs[key] = -> { fn.call.to_s }
      else
        values[key] = JSON.parse(value.to_json)
      end

      i += 2
    end

    tpl.gsub(/\{\{\s*[^}]+\s*\}\}/) do |match|
      token = match.gsub(/\A\{\{\s*|\s*\}\}\z/, "")
      next funcs[token].call if funcs.has_key?(token)

      path = token.starts_with?('.') ? token[1..] : token
      segments = path.split('.')
      next "" if segments.empty?

      current = values[segments[0]]?
      next "" unless current

      segments[1..].each do |seg|
        obj = current.as_h?
        break current = nil unless obj
        next_value = obj[seg]?
        break current = nil unless next_value
        current = next_value
      end

      current ? (current.raw.is_a?(String) ? current.as_s : current.to_json) : ""
    end
  end

  # Exec command line with stdio forwarding enabled.
  def self.exec(line : String) : String
    exec_line(true, line)
  end

  # Exec command line with stdio forwarding enabled.
  def self.exec(line : String, *rest : String) : String
    exec_line(true, line, *rest)
  end

  # ExecLine runs command. When std is false, output is captured and returned.
  def self.exec_line(std : Bool, line : String) : String
    exec_line_impl(std, line, [] of String)
  end

  # ExecLine runs command. When std is false, output is captured and returned.
  def self.exec_line(std : Bool, line : String, *rest : String) : String
    exec_line_impl(std, line, rest.to_a)
  end

  private def self.exec_line_impl(std : Bool, line : String, rest : Array(String)) : String
    args = [] of String
    unless line.empty?
      args.concat(line.split(@@reg_space).reject(&.empty?))
    end
    args.concat(rest)
    raise "empty command" if args.empty?

    output = IO::Memory.new
    error = IO::Memory.new

    status = if std
               out_writer = IO::MultiWriter.new(output, STDOUT)
               err_writer = IO::MultiWriter.new(error, STDERR)
               Process.run(args[0], args: args[1..], input: Process::Redirect::Inherit, output: out_writer, error: err_writer)
             else
               Process.run(args[0], args: args[1..], output: output, error: error)
             end

    unless status.success?
      if std
        raise "command failed: #{format_cli_args(args)}"
      end

      text = output.to_s + error.to_s
      raise "#{status}\n#{text}"
    end

    output.to_s + error.to_s
  end

  # UseNode installs Node.js and prepends returned bin path into PATH.
  def self.use_node(std : Bool) : Nil
    bin_path = if resolver = @@use_node_resolver
                 resolver.call(std).strip
               else
                 exec_line(std, "go run github.com/ysmood/use-node@latest -p v20").strip
               end

    current = ENV["PATH"]? || ""
    separator = {% if flag?(:win32) %} ';' {% else %} ':' {% end %}
    ENV["PATH"] = "#{bin_path}#{separator}#{current}"
  end

  # Sleeper function object. It receives the operation context and returns an
  # error when it should stop retrying.
  # Sleeper for retries.
  class Sleeper
    @fn : Proc(Rod::Context, Exception?)

    def initialize(@interval : Time::Span = 0.1.seconds, @timeout : Time::Span = 5.seconds)
      @fn = ->(ctx : Rod::Context) do
        return ctx.err || Rod::ContextCanceledError.new("context cancelled") if ctx.cancelled?
        ::sleep(@interval)
        nil
      end
    end

    def initialize(&block : Rod::Context -> Exception?)
      @interval = Time::Span.zero
      @timeout = Time::Span.zero
      @fn = block
    end

    def call(ctx : Rod::Context) : Exception?
      @fn.call(ctx)
    end

    def sleep : Nil
      ::sleep(@interval)
    end
  end

  # MaxSleepCountError is returned when CountSleeper exceeds max calls.
  class MaxSleepCountError < Rod::RodError
    getter max : Int32

    def initialize(@max : Int32)
      super("max sleep count #{@max} exceeded")
    end

    def is?(err : Exception.class) : Bool
      err == MaxSleepCountError
    end
  end

  # Random string generator.
  def self.rand_string(length : Int32 = 8) : String
    Random::Secure.random_bytes(length).hexstring
  end

  # AbsolutePaths returns absolute paths of files in current working directory.
  def self.absolute_paths(paths : Array(String)) : Array(String)
    abs_paths = [] of String
    paths.each do |path|
      abs_paths << File.expand_path(path)
    end
    abs_paths
  end

  # Error helper.
  def self.e(err : Exception?)
    raise err if err
  end

  # CountSleeper wakes immediately until reaching max calls.
  def self.count_sleeper(max : Int32) : Sleeper
    lock = Mutex.new
    count = 0

    Sleeper.new do |ctx|
      err : Exception? = nil
      lock.synchronize do
        if ctx.cancelled?
          err = ctx.err || Rod::ContextCanceledError.new("context cancelled")
        elsif count == max
          err = MaxSleepCountError.new(max)
        else
          count += 1
        end
      end
      err
    end
  end

  # Default backoff algorithm: A(n) = A(n-1) * random[1.9, 2.1).
  def self.default_backoff(interval : Time::Span) : Time::Span
    scale = 2.0 + (Random.rand - 0.5) * 0.2
    interval * scale
  end

  # BackoffSleeper grows sleep duration from init_interval up to max_interval.
  def self.backoff_sleeper(
    init_interval : Time::Span,
    max_interval : Time::Span,
    algorithm : Proc(Time::Span, Time::Span)? = nil,
  ) : Sleeper
    lock = Mutex.new
    algo = algorithm || ->(i : Time::Span) { default_backoff(i) }
    current = init_interval

    Sleeper.new do |ctx|
      err : Exception? = nil
      lock.synchronize do
        unless max_interval <= Time::Span::ZERO
          if ctx.cancelled?
            err = ctx.err || Rod::ContextCanceledError.new("context cancelled")
          else
            interval = current < max_interval ? algo.call(current) : max_interval
            interval = max_interval if interval > max_interval

            step = 10.milliseconds
            elapsed = Time::Span::ZERO
            while elapsed < interval
              if ctx.cancelled?
                err = ctx.err || Rod::ContextCanceledError.new("context cancelled")
                break
              end

              remaining = interval - elapsed
              nap = remaining < step ? remaining : step
              ::sleep(nap) if nap > Time::Span::ZERO
              elapsed += nap
            end

            current = interval unless err
          end
        end
      end
      err
    end
  end

  # EachSleepers wakes when each sleeper wakes in order.
  def self.each_sleepers(*list : Sleeper) : Sleeper
    Sleeper.new do |ctx|
      result : Exception? = nil
      list.each do |sleeper_fn|
        if err = sleeper_fn.call(ctx)
          result = err
          break
        end
      end
      result
    end
  end

  # RaceSleepers wakes when any one sleeper wakes.
  def self.race_sleepers(*list : Sleeper) : Sleeper
    Sleeper.new do |ctx|
      child, cancel = ctx.with_cancel
      done = Channel(Exception?).new(list.size)

      list.each do |sleeper_fn|
        spawn do
          done.send(sleeper_fn.call(child))
          cancel.call
        end
      end

      done.receive
    end
  end

  # Retry executes fn and sleeps using sleeper until fn returns true or sleeper returns error.
  def self.retry(ctx : Rod::Context, sleeper : Sleeper, &fn : -> Tuple(Bool, Exception?)) : Exception?
    loop do
      stop, err = fn.call
      return err if stop

      if sleep_err = sleeper.call(ctx)
        return sleep_err
      end
    end
  end

  # IdleCounter resolves only after no jobs are active for a duration.
  class IdleCounter
    @lock = Mutex.new
    @job = 0
    @duration : Time::Span
    @timer_token : Int64 = 0_i64
    @timer_fired = Channel(Int64).new(1)

    def initialize(@duration : Time::Span)
    end

    def add : Nil
      @lock.synchronize do
        @timer_token += 1
        @job += 1
      end
    end

    def done : Nil
      token_to_fire : Int64? = nil
      @lock.synchronize do
        @job -= 1
        raise "all jobs are already done" if @job < 0
        if @job == 0
          @timer_token += 1
          token_to_fire = @timer_token
        end
      end

      if token = token_to_fire
        token_value = token
        spawn do
          ::sleep(@duration) if @duration > Time::Span::ZERO
          @timer_fired.send(token_value)
        end
      end
    end

    def wait(ctx : Rod::Context) : Nil
      token_to_fire : Int64? = nil
      @lock.synchronize do
        if @job == 0
          @timer_token += 1
          token_to_fire = @timer_token
        end
      end

      if token = token_to_fire
        token_value = token
        spawn do
          ::sleep(@duration) if @duration > Time::Span::ZERO
          @timer_fired.send(token_value)
        end
      end

      loop do
        return if ctx.cancelled?

        select
        when token = @timer_fired.receive
          current = @lock.synchronize { @timer_token }
          return if token == current
        when ctx.done.receive
          return
        end
      end
    end
  end

  # StreamReader reads a stream from CDP IO.
  class StreamReader < IO
    @offset : Int64?
    @handle : ::Cdp::IO::StreamHandle
    @client : ::Cdp::Client
    @buffer : Bytes = Bytes.new(0)
    @buffer_pos : Int32 = 0
    @eof : Bool = false
    @closed : Bool = false

    def initialize(@client : ::Cdp::Client, @handle : ::Cdp::IO::StreamHandle, @offset : Int64? = nil)
    end

    def close : Nil
      return if @closed
      @closed = true
      ::Cdp::IO::Close.new(@handle).call(@client)
    rescue
      # Ignore errors on close
    end

    def closed? : Bool
      @closed
    end

    def read(slice : Bytes) : Int32
      raise IO::Error.new("Closed stream") if @closed
      return 0 if @eof

      # If we have data in buffer, serve from there
      if @buffer_pos < @buffer.size
        to_copy = Math.min(slice.size, @buffer.size - @buffer_pos)
        slice[0, to_copy].copy_from(@buffer[@buffer_pos, to_copy])
        @buffer_pos += to_copy
        return to_copy
      end

      # Read more data from CDP
      res = ::Cdp::IO::Read.new(@handle, @offset, nil).call(@client)

      data = res.data
      if res.base64_encoded? == true
        # Decode base64
        @buffer = Base64.decode(data)
      else
        @buffer = data.to_slice
      end

      @buffer_pos = 0
      @offset = @offset.try { |off| off + @buffer.size }
      @eof = res.eof?

      if @buffer.empty? && @eof
        return 0
      end

      # Copy to slice
      to_copy = Math.min(slice.size, @buffer.size)
      slice[0, to_copy].copy_from(@buffer[0, to_copy])
      @buffer_pos = to_copy
      to_copy
    rescue ex
      raise IO::Error.new("Stream read error: #{ex.message}", ex)
    end

    def write(slice : Bytes) : Nil
      raise IO::Error.new("StreamReader is read-only")
    end

    def flush : Nil
      # Nothing to flush
    end

    def rewind : Nil
      raise IO::Error.new("StreamReader does not support rewind")
    end
  end

  # CropImage by the specified box, quality is only for jpeg bin.
  def self.crop_image(bin : Bytes, quality : Int32, x : Int32, y : Int32, width : Int32, height : Int32) : Bytes
    io = IO::Memory.new(bin)

    # Try to detect format by magic bytes
    header = bin[0, 8]

    if header[0, 8] == Bytes[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
      image = PngProcessor.new.decode(io)
      cropped = image.crop(x, y, width, height)
      PngProcessor.new.encode(cropped, nil)
    elsif header[0, 2] == Bytes[0xFF, 0xD8]
      # JPEG
      image = Pluto::ImageRGBA.from_jpeg(io)
      cropped = image.crop(x, y, width, height)
      output = IO::Memory.new
      cropped.to_jpeg(output, quality: quality == 0 ? 80 : quality)
      output.to_slice
    else
      raise "Unsupported image format"
    end
  end

  # Rect represents a rectangle with integer coordinates.
  struct Rect
    property x : Int32
    property y : Int32
    property width : Int32
    property height : Int32

    def initialize(@x, @y, @width, @height)
    end

    # Dx returns the width of the rectangle.
    def dx : Int32
      @width
    end

    # Dy returns the height of the rectangle.
    def dy : Int32
      @height
    end
  end

  # ImgWithBox is a image with a box, if the box is nil, it means the whole image.
  struct ImgWithBox
    property img : Bytes
    property box : Rect?

    def initialize(@img : Bytes, @box : Rect? = nil)
    end
  end

  # ImgOption is the option for image processing.
  struct ImgOption
    property quality : Int32

    def initialize(@quality : Int32 = 80)
    end
  end

  # ImgProcessor handles encoding and decoding for a screenshot format.
  module ImgProcessor
    abstract def encode(img : Pluto::ImageRGBA, opt : ImgOption?) : Bytes
    abstract def decode(file : IO) : Pluto::ImageRGBA
  end

  class JpegProcessor
    include ImgProcessor

    def encode(img : Pluto::ImageRGBA, opt : ImgOption?) : Bytes
      output = IO::Memory.new
      quality = opt.try(&.quality) || 80
      img.to_jpeg(output, quality: quality)
      output.to_slice
    end

    def decode(file : IO) : Pluto::ImageRGBA
      Pluto::ImageRGBA.from_jpeg(file)
    end
  end

  class PngProcessor
    include ImgProcessor

    def encode(img : Pluto::ImageRGBA, opt : ImgOption?) : Bytes
      _ = opt
      output = IO::Memory.new
      CrImage::PNG.write(output, Rod::Util::Utils.crimage_from_pluto(img))
      output.to_slice
    end

    def decode(file : IO) : Pluto::ImageRGBA
      Rod::Util::Utils.pluto_from_crimage(CrImage::PNG.read(file))
    end
  end

  def self.crimage_from_pluto(img : Pluto::ImageRGBA) : CrImage::RGBA
    out = CrImage::RGBA.new(CrImage.rect(0, 0, img.width, img.height))
    i = 0
    img.height.times do |y|
      img.width.times do |x|
        out.set_rgba(x, y, CrImage::Color::RGBA.new(img.red[i], img.green[i], img.blue[i], img.alpha[i]))
        i += 1
      end
    end
    out
  end

  def self.pluto_from_crimage(img : CrImage::Image) : Pluto::ImageRGBA
    bounds = img.bounds
    width = bounds.width
    height = bounds.height
    size = width * height
    red = Array(UInt8).new(size, 0u8)
    green = Array(UInt8).new(size, 0u8)
    blue = Array(UInt8).new(size, 0u8)
    alpha = Array(UInt8).new(size, 0u8)

    i = 0
    (0...height).each do |y|
      (0...width).each do |x|
        color = img.at(bounds.min.x + x, bounds.min.y + y).to_rgba8
        red[i] = color.r
        green[i] = color.g
        blue[i] = color.b
        alpha[i] = color.a
        i += 1
      end
    end

    Pluto::ImageRGBA.new(red, green, blue, alpha, width, height)
  end

  # NewImgProcessor creates an image processor by screenshot format.
  def self.new_img_processor(format : String) : ImgProcessor
    case format
    when "jpeg"
      JpegProcessor.new
    when "", "png"
      PngProcessor.new
    else
      raise "not support format: #{format}"
    end
  end

  # SplicePngVertical splice png vertically, if there is only one image, it will return the image directly.
  # Only support png and jpeg format yet, webP is not supported because no suitable processing
  # library was found in Crystal.
  def self.splice_png_vertical(files : Array(ImgWithBox), format : String, opt : ImgOption? = nil) : Bytes
    return Bytes.new(0) if files.empty?
    return files[0].img if files.size == 1

    processor = new_img_processor(format)

    width = 0
    height = 0
    images = [] of Pluto::ImageRGBA

    files.each do |file|
      io = IO::Memory.new(file.img)
      image = processor.decode(io)

      images << image
      if box = file.box
        width = box.width
        height += box.height
      else
        width = image.width
        height += image.height
      end
    end

    # Create new composite image
    red = Array(UInt8).new(width * height, 0u8)
    green = Array(UInt8).new(width * height, 0u8)
    blue = Array(UInt8).new(width * height, 0u8)
    alpha = Array(UInt8).new(width * height, 0u8)

    dest_y = 0
    files.each_with_index do |file, i|
      image = images[i]
      bounds = file.box || Rect.new(0, 0, image.width, image.height)
      start_x = bounds.x
      start_y = bounds.y
      end_x = bounds.x + bounds.width
      end_y = bounds.y + bounds.height

      (bounds.y...end_y).each do |y|
        (bounds.x...end_x).each do |x|
          pixel_idx = y * image.width + x
          dest_idx = (dest_y + y - start_y) * width + (x - start_x)
          red[dest_idx] = image.red[pixel_idx]
          green[dest_idx] = image.green[pixel_idx]
          blue[dest_idx] = image.blue[pixel_idx]
          alpha[dest_idx] = image.alpha[pixel_idx]
        end
      end

      dest_y += bounds.height
    end

    composite = Pluto::ImageRGBA.new(red, green, blue, alpha, width, height)
    processor.encode(composite, opt)
  end
end
