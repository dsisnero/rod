require "base64"
require "../../cdp/io/io"
require "../../cdp/page/page"
require "pluto"

module Rod::Lib::Utils
  # Sleeper for retries.
  class Sleeper
    def initialize(@interval : Time::Span = 0.1.seconds, @timeout : Time::Span = 5.seconds)
    end

    def sleep : Nil
      ::sleep(@interval)
    end
  end

  # Random string generator.
  def self.rand_string(length : Int32 = 8) : String
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    String.new(length) { chars.sample }
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

  # Retry executes fn and sleeps using sleeper until fn returns true or context is cancelled.
  def self.retry(ctx : Rod::Context, sleeper : Sleeper, &fn : -> Tuple(Bool, Exception?)) : Exception?
    loop do
      stop, err = fn.call
      if stop
        return err
      end

      # Check context cancellation
      if ctx.cancelled?
        return ctx.err || Rod::ContextCanceledError.new("context cancelled")
      end

      # Sleep using sleeper
      sleeper.sleep
    end
  rescue ex : Exception
    ex
  end

  # StreamReader reads a stream from CDP IO.
  class StreamReader
    include IO::Buffered

    @offset : Int64?
    @handle : ::Cdp::IO::StreamHandle
    @client : Cdp::Client
    @buffer : Bytes = Bytes.new(0)
    @buffer_pos : Int32 = 0
    @eof : Bool = false

    def initialize(@client : Cdp::Client, @handle : ::Cdp::IO::StreamHandle, @offset : Int64? = nil)
    end

    private def unbuffered_close : Nil
      Cdp::IO::Close.new(@handle).call(@client)
    rescue
      # Ignore errors on close
    end

    private def unbuffered_read(slice : Bytes) : Int32
      return 0 if @eof

      # If we have data in buffer, serve from there
      if @buffer_pos < @buffer.size
        to_copy = Math.min(slice.size, @buffer.size - @buffer_pos)
        slice[0, to_copy] = @buffer[@buffer_pos, to_copy]
        @buffer_pos += to_copy
        return to_copy
      end

      # Read more data from CDP
      res = Cdp::IO::Read.new(@handle, @offset, nil).call(@client)
      if res.eof
        @eof = true
        return 0
      end

      data = res.data
      if res.base64_encoded == true
        # Decode base64
        @buffer = Base64.decode(data)
      else
        @buffer = data.to_slice
      end

      @buffer_pos = 0
      @offset = @offset.try { |off| off + @buffer.size }

      # Copy to slice
      to_copy = Math.min(slice.size, @buffer.size)
      slice[0, to_copy] = @buffer[0, to_copy]
      @buffer_pos = to_copy
      to_copy
    rescue ex
      raise IO::Error.new("Stream read error: #{ex.message}", ex)
    end

    private def unbuffered_write(slice : Bytes) : Nil
      raise IO::Error.new("StreamReader is read-only")
    end

    private def unbuffered_flush : Nil
      # Nothing to flush
    end

    private def unbuffered_rewind : Nil
      raise IO::Error.new("StreamReader does not support rewind")
    end
  end

  # CropImage by the specified box, quality is only for jpeg bin.
  def crop_image(bin : Bytes, quality : Int32, x : Int32, y : Int32, width : Int32, height : Int32) : Bytes
    io = IO::Memory.new(bin)

    # Try to detect format by magic bytes
    header = bin[0, 8]

    if header[0, 8] == Bytes[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
      # PNG
      image = Pluto::PNG.read(io)
      cropped = image.crop(x, y, width, height)
      output = IO::Memory.new
      Pluto::PNG.write(output, cropped)
      output.to_slice
    elsif header[0, 2] == Bytes[0xFF, 0xD8]
      # JPEG
      image = Pluto::JPEG.read(io)
      cropped = image.crop(x, y, width, height)
      output = IO::Memory.new
      Pluto::JPEG.write(output, cropped, quality: quality == 0 ? 80 : quality)
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

  # SplicePngVertical splice png vertically, if there is only one image, it will return the image directly.
  # Only support png and jpeg format yet, webP is not supported because no suitable processing
  # library was found in Crystal.
  def splice_png_vertical(files : Array(ImgWithBox), format : Cdp::Page::CaptureScreenshotFormat, opt : ImgOption? = nil) : Bytes
    return Bytes.new(0) if files.empty?
    return files[0].img if files.size == 1

    width = 0
    height = 0
    images = [] of Pluto::ImageRGBA

    files.each do |file|
      io = IO::Memory.new(file.img)
      # Detect format by magic bytes or use specified format
      header = file.img[0, 8]
      image = if header[0, 8] == Bytes[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
                # PNG
                Pluto::PNG.read(io).as(Pluto::ImageRGBA)
              elsif header[0, 2] == Bytes[0xFF, 0xD8]
                # JPEG
                Pluto::JPEG.read(io).as(Pluto::ImageRGBA)
              else
                # Fallback to format parameter
                case format
                when Cdp::Page::CaptureScreenshotFormatJpeg
                  Pluto::JPEG.read(io).as(Pluto::ImageRGBA)
                else # PNG default
                  Pluto::PNG.read(io).as(Pluto::ImageRGBA)
                end
              end

      images << image
      if box = file.box
        width = box.width if width == 0
        height += box.height
      else
        width = image.width if width == 0
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
    output = IO::Memory.new

    case format
    when Cdp::Page::CaptureScreenshotFormatJpeg
      quality = opt.try(&.quality) || 80
      Pluto::JPEG.write(output, composite, quality: quality)
    else # PNG default
      Pluto::PNG.write(output, composite)
    end

    output.to_slice
  end
end
