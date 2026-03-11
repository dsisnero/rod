require "spec"
require "../src/rod"
require "pluto/format/jpeg"
require "file_utils"

private class FakeStreamClient < Cdp::Client
  @responses = Deque(String).new
  @errors = Deque(Exception).new

  def enqueue_response(json : String) : Nil
    @responses << json
  end

  def enqueue_error(ex : Exception) : Nil
    @errors << ex
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    if error = @errors.shift?
      raise error
    end

    response = @responses.shift? || %({"data":"","eof":true})
    response.to_slice
  end
end

private def make_jpeg(width : Int32, height : Int32) : Bytes
  size = width * height
  red = Array(UInt8).new(size, 200u8)
  green = Array(UInt8).new(size, 100u8)
  blue = Array(UInt8).new(size, 50u8)
  alpha = Array(UInt8).new(size, 255u8)
  image = Pluto::ImageRGBA.new(red, green, blue, alpha, width, height)

  io = IO::Memory.new
  image.to_jpeg(io, quality: 80)
  io.to_slice
end

private def fake_png(width : Int32, height : Int32) : Bytes
  io = IO::Memory.new
  io.write(Bytes[0x89u8, 0x50u8, 0x4Eu8, 0x47u8, 0x0Du8, 0x0Au8, 0x1Au8, 0x0Au8])
  io.write_bytes(13u32, IO::ByteFormat::BigEndian)
  io.write("IHDR".to_slice)
  io.write_bytes(width.to_u32, IO::ByteFormat::BigEndian)
  io.write_bytes(height.to_u32, IO::ByteFormat::BigEndian)
  io.write(Bytes[8u8, 2u8, 0u8, 0u8, 0u8])
  io.write_bytes(0u32, IO::ByteFormat::BigEndian)
  io.write_bytes(0u32, IO::ByteFormat::BigEndian)
  io.write("IEND".to_slice)
  io.write_bytes(0u32, IO::ByteFormat::BigEndian)
  io.to_slice
end

private def parse_png_size(bin : Bytes) : Tuple(Int32, Int32)
  io = IO::Memory.new(bin)
  sig = Bytes.new(8)
  io.read_fully(sig)
  unless sig == Bytes[0x89u8, 0x50u8, 0x4Eu8, 0x47u8, 0x0Du8, 0x0Au8, 0x1Au8, 0x0Au8]
    raise "invalid png signature"
  end
  length = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)
  type = Bytes.new(4)
  io.read_fully(type)
  raise "invalid ihdr" unless length == 13 && type == "IHDR".to_slice
  width = io.read_bytes(UInt32, IO::ByteFormat::BigEndian).to_i32
  height = io.read_bytes(UInt32, IO::ByteFormat::BigEndian).to_i32
  {width, height}
end

private class ScreenshotStubPage < Rod::Page
  getter methods = [] of String
  @responses = {} of String => String
  @failures = {} of String => Exception

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def set_response(method : String, payload : String) : Nil
    @responses[method] = payload
  end

  def set_failure(method : String, ex : Exception) : Nil
    @failures[method] = ex
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @methods << method
    if ex = @failures[method]?
      raise ex
    end
    payload = @responses[method]?
    raise "missing stub for method #{method}" unless payload
    payload.to_slice
  end
end

describe Rod::Page do
  it "#screenshot returns screenshot data" do
    page = ScreenshotStubPage.new
    page.set_response("Page.captureScreenshot", %({"data":"dGVzdA=="}))

    page.screenshot.should eq("test".to_slice)
  end

  it "#must_screenshot writes binary output to file" do
    page = ScreenshotStubPage.new
    page.set_response("Page.captureScreenshot", %({"data":"dGVzdA=="}))
    FileUtils.mkdir_p("./temp")
    path = "./temp/spec-screenshot-#{Random::Secure.hex(8)}.png"

    begin
      bin = page.must_screenshot(path)
      bin.should eq("test".to_slice)
      File.exists?(path).should be_true
      File.read(path).to_slice.should eq(bin)
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  it "#must_screenshot with empty path writes to tmp/screenshots" do
    page = ScreenshotStubPage.new
    page.set_response("Page.captureScreenshot", %({"data":"dGVzdA=="}))
    FileUtils.mkdir_p("tmp/screenshots")
    before = Dir.glob("tmp/screenshots/*.png")

    created = ""
    begin
      page.must_screenshot("")
      after = Dir.glob("tmp/screenshots/*.png")
      created_paths = after.reject { |path| before.includes?(path) }
      created_paths.size.should eq(1)
      created = created_paths.first
      File.read(created).to_slice.should eq("test".to_slice)
    ensure
      if !created.empty? && File.exists?(created)
        File.delete(created)
      end
    end
  end

  it "#must_screenshot exposes PNG dimensions from screenshot bytes" do
    page = ScreenshotStubPage.new
    image = fake_png(1280, 800)
    page.set_response("Page.captureScreenshot", %({"data":"#{Base64.strict_encode(image)}"}))

    bin = page.must_screenshot
    width, height = parse_png_size(bin)
    width.should eq(1280)
    height.should eq(800)
  end

  it "#screenshot propagates page capture errors" do
    page = ScreenshotStubPage.new
    page.set_failure("Page.captureScreenshot", Exception.new("capture failed"))

    expect_raises(Exception, /capture failed/) { page.screenshot }
  end

  it "#screenshot restores viewport after full page screenshot" do
    page = ScreenshotStubPage.new
    metrics = %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":50},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":50.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":50},
      "cssVisualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":50.0,"scale":1.0},
      "cssContentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0}
    })
    page.set_response("Page.getLayoutMetrics", metrics)
    page.set_response("Page.captureScreenshot", %({"data":"ZnVsbA=="}))
    page.set_response("Emulation.setDeviceMetricsOverride", %({}))
    page.set_response("Emulation.clearDeviceMetricsOverride", %({}))

    page.screenshot(full_page: true).should eq("full".to_slice)
    page.methods.should contain("Emulation.setDeviceMetricsOverride")
    page.methods.should contain("Emulation.clearDeviceMetricsOverride")
  end

  it "#scroll_screenshot returns scroll screenshot data" do
    page = ScreenshotStubPage.new
    metrics = %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":80.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "cssVisualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "cssContentSize":{"x":0.0,"y":0.0,"width":100.0,"height":80.0}
    })
    page.set_response("Page.getLayoutMetrics", metrics)
    page.set_response("Page.captureScreenshot", %({"data":"c2Nyb2xs"}))

    result = page.scroll_screenshot(Rod::ScrollScreenshotOptions.new(format: "jpeg"))
    result.should eq("scroll".to_slice)
  end

  it "#scroll_screenshot supports PNG format only" do
    expect_raises(Exception, /not support format/) do
      Rod::Lib::Utils.splice_png_vertical(
        [
          Rod::Lib::Utils::ImgWithBox.new(Bytes[1]),
          Rod::Lib::Utils::ImgWithBox.new(Bytes[2]),
        ],
        "webp"
      )
    end
  end

  it "#scroll_screenshot propagates layout metrics errors" do
    page = ScreenshotStubPage.new
    page.set_failure("Page.getLayoutMetrics", Exception.new("layout failed"))

    expect_raises(Exception, /layout failed/) { page.scroll_screenshot }
  end

  it "#scroll_screenshot errors when css visual viewport is missing" do
    page = ScreenshotStubPage.new
    page.set_response("Page.getLayoutMetrics", %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "cssContentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0}
    }))

    expect_raises(Exception, /failed to get css visual viewport/) { page.scroll_screenshot }
  end

  it "#scroll_screenshot errors when css content size is missing" do
    page = ScreenshotStubPage.new
    page.set_response("Page.getLayoutMetrics", %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "cssVisualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0}
    }))

    expect_raises(Exception, /failed to get css content size/) { page.scroll_screenshot }
  end

  it "#scroll_screenshot propagates mouse scroll dispatch errors" do
    page = ScreenshotStubPage.new
    page.set_response("Page.getLayoutMetrics", %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "cssVisualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "cssContentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0}
    }))
    page.set_response("Page.captureScreenshot", %({"data":"c2Nyb2xs"}))
    page.set_failure("Input.dispatchMouseEvent", Exception.new("scroll failed"))

    expect_raises(Exception, /scroll failed/) { page.scroll_screenshot }
  end

  it "#scroll_screenshot propagates screenshot capture errors" do
    page = ScreenshotStubPage.new
    page.set_response("Page.getLayoutMetrics", %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "cssVisualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "cssContentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0}
    }))
    page.set_failure("Page.captureScreenshot", Exception.new("capture failed"))

    expect_raises(Exception, /capture failed/) { page.scroll_screenshot }
  end

  it "#scroll_screenshot propagates wait_dom_stable errors" do
    page = ScreenshotStubPage.new
    page.set_response("Page.getLayoutMetrics", %({
      "layoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "visualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "contentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0},
      "cssLayoutViewport":{"pageX":0,"pageY":0,"clientWidth":100,"clientHeight":100},
      "cssVisualViewport":{"offsetX":0.0,"offsetY":0.0,"pageX":0.0,"pageY":0.0,"clientWidth":100.0,"clientHeight":100.0,"scale":1.0},
      "cssContentSize":{"x":0.0,"y":0.0,"width":100.0,"height":300.0}
    }))
    page.set_response("Page.captureScreenshot", %({"data":"c2Nyb2xs"}))
    page.set_response("Input.dispatchMouseEvent", %({}))
    page.set_failure("DOMSnapshot.captureSnapshot", Exception.new("wait stable failed"))

    expect_raises(Exception, /wait stable failed/) { page.scroll_screenshot }
  end

  it "#pdf returns PDF stream" do
    page = ScreenshotStubPage.new
    page.set_response("Page.printToPDF", %({"data":"","stream":"stream-handle"}))

    reader = page.pdf
    reader.should be_a(Rod::Lib::Utils::StreamReader)
  end

  it "#pdf propagates print_to_pdf errors" do
    page = ScreenshotStubPage.new
    page.set_failure("Page.printToPDF", Exception.new("pdf failed"))

    expect_raises(Exception, /pdf failed/) { page.pdf }
  end

  it "#must_pdf writes binary output to file" do
    page = ScreenshotStubPage.new
    page.set_response("Page.printToPDF", %({"data":"","stream":"stream-handle"}))
    page.set_response("IO.read", %({"base64Encoded":true,"data":"dGVzdC1wZGY=","eof":true}))
    page.set_response("IO.close", %({}))
    FileUtils.mkdir_p("./temp")
    path = "./temp/spec-pdf-#{Random::Secure.hex(8)}.pdf"

    begin
      bin = page.must_pdf(path)
      bin.should eq("test-pdf".to_slice)
      File.exists?(path).should be_true
      File.read(path).to_slice.should eq(bin)
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  it "#must_pdf with empty path writes to tmp/pdf" do
    page = ScreenshotStubPage.new
    page.set_response("Page.printToPDF", %({"data":"","stream":"stream-handle"}))
    page.set_response("IO.read", %({"base64Encoded":true,"data":"dGVzdC1wZGY=","eof":true}))
    page.set_response("IO.close", %({}))
    FileUtils.mkdir_p("tmp/pdf")
    before = Dir.glob("tmp/pdf/*.pdf")

    created = ""
    begin
      page.must_pdf("")
      after = Dir.glob("tmp/pdf/*.pdf")
      created_paths = after.reject { |path| before.includes?(path) }
      created_paths.size.should eq(1)
      created = created_paths.first
      File.read(created).to_slice.should eq("test-pdf".to_slice)
    ensure
      if !created.empty? && File.exists?(created)
        File.delete(created)
      end
    end
  end
end

describe Rod::Lib::Utils::StreamReader do
  it "#read reads stream data and surfaces CDP read errors" do
    client = FakeStreamClient.new
    reader = Rod::Lib::Utils::StreamReader.new(client, "")

    client.enqueue_response(%({"data":"test","eof":false}))
    bytes = Bytes.new(4)
    n = reader.read(bytes)
    n.should eq(4)
    String.new(bytes).should eq("test")

    client.enqueue_error(Exception.new("mock read failure"))
    expect_raises(IO::Error) do
      reader.read(Bytes.new(1))
    end

    client.enqueue_response(%({"base64Encoded":true,"data":"@","eof":false}))
    expect_raises(IO::Error) do
      reader.read(Bytes.new(1))
    end
  end
end

describe "Image utilities" do
  it "#crop_image crops image to specified rectangle" do
    img = make_jpeg(100, 100)
    result = Rod::Lib::Utils.crop_image(img, 80, 10, 10, 30, 30)
    decoded = Pluto::ImageRGBA.from_jpeg(IO::Memory.new(result))

    decoded.width.should eq(30)
    decoded.height.should eq(30)
  end

  it "#splice_png_vertical splices PNGs vertically" do
    a = make_jpeg(1000, 200)
    b = make_jpeg(1000, 300)
    result = Rod::Lib::Utils.splice_png_vertical(
      [
        Rod::Lib::Utils::ImgWithBox.new(a),
        Rod::Lib::Utils::ImgWithBox.new(b),
      ],
      "jpeg",
      Rod::Lib::Utils::ImgOption.new(80)
    )
    decoded = Pluto::ImageRGBA.from_jpeg(IO::Memory.new(result))

    decoded.width.should eq(1000)
    decoded.height.should eq(500)
  end

  it "#splice_png_vertical supports jpeg crop boxes" do
    a = make_jpeg(1000, 200)
    b = make_jpeg(1000, 300)
    result = Rod::Lib::Utils.splice_png_vertical(
      [
        Rod::Lib::Utils::ImgWithBox.new(
          a,
          Rod::Lib::Utils::Rect.new(0, 0, 1000, 100)
        ),
        Rod::Lib::Utils::ImgWithBox.new(b),
      ],
      "jpeg"
    )
    decoded = Pluto::ImageRGBA.from_jpeg(IO::Memory.new(result))

    decoded.width.should eq(1000)
    decoded.height.should eq(400)
  end

  it "#splice_png_vertical returns empty bytes when no input files are provided" do
    Rod::Lib::Utils.splice_png_vertical([] of Rod::Lib::Utils::ImgWithBox, "jpeg").should eq(Bytes.new(0))
  end

  it "#splice_png_vertical returns input unchanged for one file" do
    only = Bytes[1, 2, 3]
    result = Rod::Lib::Utils.splice_png_vertical(
      [Rod::Lib::Utils::ImgWithBox.new(only)],
      "jpeg"
    )

    result.should eq(only)
  end

  it "#splice_png_vertical raises on invalid image payloads" do
    expect_raises(Exception) do
      Rod::Lib::Utils.splice_png_vertical(
        [
          Rod::Lib::Utils::ImgWithBox.new(Bytes[1]),
          Rod::Lib::Utils::ImgWithBox.new(Bytes[2]),
        ],
        "jpeg"
      )
    end
  end

  it "#new_img_processor creates supported processors and round-trips dimensions" do
    [
      {"jpeg", false},
      {"webp", true},
    ].each do |format, want_err|
      if want_err
        expect_raises(Exception, /not support format/) { Rod::Lib::Utils.new_img_processor(format) }
        next
      end

      processor = Rod::Lib::Utils.new_img_processor(format)
      input = Pluto::ImageRGBA.from_jpeg(IO::Memory.new(make_jpeg(1000, 200)))
      encoded = processor.encode(input, nil)
      decoded = processor.decode(IO::Memory.new(encoded))
      decoded.width.should eq(1000)
      decoded.height.should eq(200)
      expect_raises(Exception) { processor.decode(IO::Memory.new(Bytes.empty)) }
    end
  end

  it "#new_img_processor supports png and default format parity" do
    ["", "png"].each do |format|
      processor = Rod::Lib::Utils.new_img_processor(format)
      input = Pluto::ImageRGBA.from_jpeg(IO::Memory.new(make_jpeg(1000, 200)))
      encoded = processor.encode(input, nil)
      width, height = parse_png_size(encoded)
      width.should eq(1000)
      height.should eq(200)

      decoded = processor.decode(IO::Memory.new(encoded))
      decoded.width.should eq(1000)
      decoded.height.should eq(200)

      expect_raises(Exception) { processor.decode(IO::Memory.new(Bytes.empty)) }
    end
  end
end
