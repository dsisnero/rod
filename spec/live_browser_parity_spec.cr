require "./spec_helper"
require "base64"
require "http/server"
require "http/client"
require "pluto/format/jpeg"

private CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

private def fixture_url(name : String) : String
  "file://#{File.expand_path("vendor/rod/fixtures/#{name}", Dir.current)}"
end

private def with_live_browser(& : Rod::Browser ->)
  launcher = Rod::Lib::Launcher::Launcher.new
    .bin(CHROME_BIN)
    .headless(true)
    .no_sandbox(true)
    .leakless(false)

  browser = Rod::Browser.new.control_url(launcher.launch)
  browser.connect

  begin
    yield browser
  ensure
    begin
      browser.close
    rescue
    end

    begin
      launcher.kill
    rescue
    end
  end
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

describe "live browser parity" do
  it "matches TestGetPageURL behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click-iframe.html"))
      page.must_wait_load
      page.must_info.url.should match(/\/fixtures\/click-iframe\.html$/)
      page.must_close
    end
  end

  it "matches TestPageElements behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("input.html"))
      page.must_wait_load
      page.must_element("input")
      list = page.must_elements("input")

      list.first.not_nil!.must_describe.local_name.should eq("input")
      list.last.not_nil!.must_text.should eq("submit")
      page.must_close
    end
  end

  it "matches pages query behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      pages = browser.must_pages
      pages.must_find("button").must_has("button").should be_true
      pages.must_find_by_url("click\\.html").must_has("button").should be_true

      page.must_close
    end
  end

  it "matches search behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      el = page.must_search("click me")
      el.must_text.should eq("click me")
      el.must_click
      page.must_wait_idle
      page.must_has("[a=ok]").should be_true

      page.must_close
    end
  end

  it "matches TestPageElementByJS behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      page.must_element_by_js("() => document.querySelector('button')").must_text.should eq("click me")

      ex = expect_raises(Rod::ExpectElementError) do
        page.must_element_by_js("() => 1")
      end
      ex.message.to_s.should contain("expect js to return an element")

      page.must_close
    end
  end

  it "matches TestClick/TestCheckbox/TestEnter/TestHover behavior with real browser" do
    with_live_browser do |browser|
      click_page = browser.must_page(fixture_url("click.html"))
      click_page.must_wait_load
      click_btn = click_page.must_element("button")
      click_btn.must_click
      click_page.must_has("[a=ok]").should be_true
      click_page.must_close

      hover_page = browser.must_page(fixture_url("click.html"))
      hover_page.must_wait_load
      hover_btn = hover_page.must_element("button")
      hover_btn.must_eval("() => this.onmouseenter = () => this.dataset['a'] = 1")
      hover_btn.must_hover
      hover_btn.must_eval("() => this.dataset['a']").as_s.should eq("1")
      hover_page.must_close

      input_page = browser.must_page(fixture_url("input.html"))
      input_page.must_wait_load

      checkbox = input_page.must_element("[type=checkbox]")
      checkbox.must_click.must_property("checked").as_bool.should be_true

      submit = input_page.must_element("[type=submit]")
      submit.must_type([Rod::Input::ENTER])
      input_page.must_has("[event=submit]").should be_true

      input_page.must_close
    end
  end

  it "matches TestClickWrapped behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click-wrapped.html"))
      page.must_wait_load

      el = page.must_element("#target")
      el.shape.quads.size.should eq(2)
      el.must_click
      page.must_has("[a=ok]").should be_true

      page.must_close
    end
  end

  it "matches TestNotInteractable behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      button = page.must_element("button")
      page.must_eval(<<-JS)
        () => {
          const div = document.createElement('div')
          div.style = 'position:absolute; left:0; top:0; width:500px; height:500px;'
          document.body.append(div)
        }
      JS

      expect_raises(Rod::CoveredError) { button.interactable }
      page.must_eval("() => document.querySelector('div').remove()")
      button.interactable

      page.must_close
    end
  end

  it "matches TestKeyType/TestInput behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("input.html"))
      page.must_wait_load

      text_input = page.must_element("[type=text]")
      text_input.key_actions.type(Rod::Input::DIGIT1, Rod::Input::DIGIT2, Rod::Input::BACKSPACE, Rod::Input::SPACE).do
      text_input.key_actions
        .type('A'.ord, Rod::Input::SPACE, Rod::Input::KEY_B)
        .do
      page.insert_text(" test")
      page.keyboard.type(Rod::Input::TAB)
      text_input.must_text.should eq("1 A b test")

      text = "雲の上は\nいつも晴れ"
      editable = page.must_element("[contenteditable=true]")
      editable.must_input(text)
      editable.must_text.should eq(text)

      textarea = page.must_element("textarea")
      textarea.must_input(text)
      textarea.must_text.should eq(text)
      page.must_has("[event=textarea-change]").should be_true

      page.must_close
    end
  end

  it "matches TestMouseDrag behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("drag.html"))
      page.must_wait_load

      mouse = page.mouse
      mouse.move_to(Rod::Point.new(3, 3))
      mouse.down("left")
      mouse.move_linear(Rod::Point.new(60, 80), 3)
      mouse.up("left")

      sleep 300.milliseconds
      page.must_eval("() => dragTrack").as_s.should eq(" move 3 3 down 3 3 move 22 28 move 41 54 move 60 80 up 60 80")

      page.must_close
    end
  end

  it "matches TestTap behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load
      page.must_emulate(Rod::Lib::Devices::IPad)
      page.must_navigate(fixture_url("touch.html"))
      page.must_wait_load

      page.must_element("button").must_tap
      page.must_has("[tapped=true]").should be_true

      page.must_close
    end
  end

  it "matches TestSetViewport/TestEmulateDevice behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load
      page.must_set_viewport(317, 419, 0, false)

      viewport = page.must_eval("() => [window.innerWidth, window.innerHeight]")
      viewport[0].as_i.should eq(317)
      viewport[1].as_i.should eq(419)

      page2 = browser.must_page("about:blank")
      page2.must_wait_load
      viewport2 = page2.must_eval("() => [window.innerWidth, window.innerHeight]")
      viewport2[0].as_i.should_not eq(317)

      page.must_emulate(Rod::Lib::Devices::IPhone6or7or8)
      emulated = page.must_eval("() => [window.innerWidth, window.innerHeight, navigator.userAgent]")
      (980 - emulated[0].as_i).abs.should be < 10
      (1743 - emulated[1].as_i).abs.should be < 10
      emulated[2].as_s.should eq("Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1")

      page.must_close
      page2.must_close
    end
  end

  it "matches TestScreenshotFullPage and TestScreenshotFullPageInit with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("scroll.html"))
      page.must_wait_load
      page.must_element("button")

      data = page.must_screenshot_full_page
      width, height = parse_png_size(data)
      size = page.must_eval("() => ({w: document.documentElement.scrollWidth, h: document.documentElement.scrollHeight})")
      width.should eq(size["w"].as_i)
      height.should eq(size["h"].as_i)

      viewport = page.must_eval("() => ({w: innerWidth, h: innerHeight})")
      viewport["w"].as_i.should eq(1280)
      viewport["h"].as_i.should eq(800)

      page.must_screenshot_full_page

      no_emulation = browser.must_page("about:blank")
      no_emulation.must_wait_load
      no_emulation.set_viewport(nil)
      no_emulation.must_screenshot_full_page

      page.must_close
      no_emulation.must_close
    end
  end

  it "matches TestScrollScreenshot behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("scroll-y.html"))
      page.must_wait_load
      page.must_element("button")

      data = page.scroll_screenshot(Rod::ScrollScreenshotOptions.new(format: "jpeg"))
      img = Pluto::ImageRGBA.from_jpeg(IO::Memory.new(data))
      size = page.must_eval("() => ({w: document.documentElement.scrollWidth, h: document.documentElement.scrollHeight})")

      (1280 >= img.width || 1000 <= img.width).should be_true
      img.height.should eq(size["h"].as_i)

      viewport = page.must_eval("() => ({w: innerWidth, h: innerHeight})")
      viewport["w"].as_i.should eq(1280)
      viewport["h"].as_i.should eq(800)

      page.scroll_screenshot(Rod::ScrollScreenshotOptions.new(format: "jpeg"))

      no_emulation = browser.must_page("about:blank")
      no_emulation.must_wait_load
      no_emulation.set_viewport(nil)
      no_emulation.scroll_screenshot(Rod::ScrollScreenshotOptions.new(format: "jpeg"))

      page.must_close
      no_emulation.must_close
    end
  end

  it "matches TestPageNavigation behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_reload

      wait = page.must_wait_navigation("DOMContentLoaded")
      page.must_navigate(fixture_url("click.html"))
      wait.call

      wait = page.must_wait_navigation("DOMContentLoaded")
      page.must_navigate(fixture_url("selector.html"))
      wait.call

      wait = page.must_wait_navigation("DOMContentLoaded")
      page.must_navigate_back
      wait.call
      page.must_info.url.should match(/\/fixtures\/click\.html$/)

      wait = page.must_wait_navigation("DOMContentLoaded")
      page.must_navigate_forward
      wait.call
      page.must_info.url.should match(/\/fixtures\/selector\.html$/)

      page.must_close
    end
  end

  it "matches TestElementInputDate/TestSelectQuery/TestSelectOptions with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("input.html"))
      page.must_wait_load

      page.must_element("[type=date]").must_input("12")

      select_el = page.must_element("select")
      select_el.select(["[value=\"c\"]"], true, Rod::SelectorType::CSSSelector)
      select_el.must_eval("() => this.selectedIndex").as_i.should eq(2)

      select_el.must_select("B", "C")
      select_el.must_text.should eq("B,C")
      select_el.must_property("selectedIndex").as_i.should eq(1)

      page.must_close
    end
  end

  it "matches TestElementMoveMouseOut/TestElementMultipleTimes/TestElementWaitLoad with real browser" do
    with_live_browser do |browser|
      click_page = browser.must_page(fixture_url("click.html"))
      click_page.must_wait_load

      btn = click_page.must_element("button")
      btn.must_eval("() => this.onmouseout = () => this.setAttribute(\"name\", \"mouse moved.\")")
      btn.must_hover.must_move_mouse_out
      btn.must_attribute("name").should eq("mouse moved.")

      btn01 = click_page.must_element("button")
      btn02 = click_page.must_element("button")
      btn01.must_text.should eq(btn02.must_text)
      btn01.object.object_id.should_not eq(btn02.object.object_id)

      click_page.must_close

      resource_page = browser.must_page(fixture_url("resource.html"))
      resource_page.must_wait_load
      resource_page.must_element("img").must_wait_load
      resource_page.must_close
    end
  end

  it "matches TestPageSlowRender behavior with real browser fixture" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("slow-render.html"))
      page.must_element("div").must_text.should eq("ok")
      page.must_close
    end
  end

  it "matches TestElementScreenshot behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      Dir.mkdir_p("tmp/screenshots")
      path = File.join("tmp", "screenshots", "#{Random::Secure.hex(8)}.png")

      begin
        data = page.must_element("h4").must_screenshot(path)
        width, height = parse_png_size(data)
        width.should eq(200)
        height.should eq(30)
        File.exists?(path).should be_true
      ensure
        File.delete(path) if File.exists?(path)
        page.must_close
      end
    end
  end

  it "matches TestResource/TestBackgroundImage fixture byte-size behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("resource.html"))
      page.must_wait_load

      img = page.must_element("img")
      img.must_wait_load
      img.must_resource.size.should eq(22661)

      div = page.must_element("div")
      div.must_background_image.size.should eq(22661)

      page.must_close
    end
  end

  it "matches TestFnErr behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load
      el = page.must_element("button")

      ex = expect_raises(Rod::EvalError) { el.must_eval("foo()") }
      ex.message.to_s.should contain("ReferenceError")

      ex = expect_raises(Rod::EvalError) { el.must_element_by_js("() => foo()") }
      ex.message.to_s.should contain("ReferenceError")

      page.must_close
    end
  end

  it "matches TestConcurrentEval behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      results = Channel(Int32).new(2)
      started = Time.instant

      wait = Rod::Lib::Utils.all(
        -> do
          value = page.eval("() => new Promise(r => setTimeout(r, 2500, 2))")
          results.send(value.value.not_nil!.as_i)
        end,
        -> do
          value = page.eval("() => new Promise(r => setTimeout(r, 1500, 1))")
          results.send(value.value.not_nil!.as_i)
        end
      )
      wait.call
      elapsed = Time.instant - started

      [results.receive, results.receive].should eq([1, 2])
      elapsed.should be > 1.5.seconds
      elapsed.should be < 3.seconds

      page.must_close
    end
  end

  it "matches TestPageEval behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      page.eval("(a, b) => a + b", [JSON::Any.new(1), JSON::Any.new(2)]).value.not_nil!.as_i.should eq(3)
      page.eval("(a, b, c, d) => a + b + c + d", [JSON::Any.new(1), JSON::Any.new(2), JSON::Any.new(3), JSON::Any.new(4)]).value.not_nil!.as_i.should eq(10)
      page.eval("function() { return 11 }").value.not_nil!.as_i.should eq(11)
      page.eval(" ; () => 1; ").value.not_nil!.as_i.should eq(1)

      fn_obj = page.evaluate(Rod::EvalOptions.new(js: "() => () => 'ok'").by_object)
      page.evaluate(Rod::EvalOptions.new(
        js: "f => f()",
        js_args: [fn_obj] of Rod::EvalOptions::JsArg
      )).value.not_nil!.as_s.should eq("ok")

      expect_raises(Exception, /apply is not a function/) do
        page.eval("10")
      end

      err = expect_raises(Rod::EvalError) do
        page.eval("() => notExist()")
      end
      err.message.to_s.should contain("notExist is not defined")

      page.must_close
    end
  end

  it "matches TestPageObjCrossNavigation behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      obj = page.evaluate(Rod::EvalOptions.new(js: "() => ({})").by_object)
      page.must_navigate("about:blank")
      page.must_wait_load

      err = expect_raises(Rod::ObjectNotFoundError) do
        page.evaluate(Rod::EvalOptions.new(js: "() => 1").this(obj))
      end
      err.message.to_s.should contain("cannot find object")

      page.must_close
    end
  end

  it "matches TestEvalObjectReferenceChainIsTooLong behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      obj = page.evaluate(Rod::EvalOptions.new(js: <<-JS).by_object)
        () => {
          let a = {b: 1}
          a.c = a
          return a
        }
      JS

      err = expect_raises(Exception) do
        page.evaluate(Rod::EvalOptions.new(
          js: "a => a",
          js_args: [obj] of Rod::EvalOptions::JsArg
        ))
      end
      err.message.to_s.should contain("Object reference chain is too long")

      val = page.evaluate(Rod::EvalOptions.new(
        js: "a => a.c.c.c.c.b",
        js_args: [obj] of Rod::EvalOptions::JsArg
      ))
      val.value.not_nil!.as_i.should eq(1)

      page.must_close
    end
  end

  it "matches TestPromiseLeak behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      wait = Rod::Lib::Utils.all(
        -> do
          expect_raises(Exception, /#{Regex.escape(Cdp::ErrCtxDestroyed.message)}/) do
            page.eval("() => new Promise(r => setTimeout(() => r(location.href), 1000))")
          end
        end,
        -> do
          sleep 300.milliseconds
          page.must_navigate("about:blank")
          page.must_wait_load
        end
      )
      wait.call

      page.must_close
    end
  end

  it "matches TestObjectLeak behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      obj = page.evaluate(Rod::EvalOptions.new(js: "() => ({a: 1})").by_object)
      page.must_reload
      page.must_wait_load

      expect_raises(Exception) do
        page.evaluate(Rod::EvalOptions.new(
          js: "obj => obj",
          js_args: [obj] of Rod::EvalOptions::JsArg
        ))
      end

      page.must_close
    end
  end

  it "matches TestCanvasToImage behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("canvas.html"))
      page.must_wait_load

      png = page.must_element("#canvas").must_canvas_to_image
      encoded = Base64.strict_encode(png)
      rgba = page.must_eval(<<-JS, [JSON::Any.new(encoded)])
        (b64) => new Promise((resolve, reject) => {
          const img = new Image()
          img.onload = () => {
            const c = document.createElement('canvas')
            c.width = img.width
            c.height = img.height
            const ctx = c.getContext('2d')
            ctx.drawImage(img, 0, 0)
            const d = ctx.getImageData(50, 50, 1, 1).data
            resolve([d[0], d[1], d[2], d[3]])
          }
          img.onerror = reject
          img.src = 'data:image/png;base64,' + b64
        })
      JS

      rgba[0].as_i.should eq(255)
      rgba[1].as_i.should eq(0)
      rgba[2].as_i.should eq(0)
      rgba[3].as_i.should eq(255)

      page.must_close
    end
  end

  it "matches TestShadowDOM behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("shadow-dom.html"))
      page.must_wait_load

      host = page.must_element("#container")
      host.must_shadow_root.must_element("p").must_text.should eq("inside")

      no_shadow = page.must_element("script")
      expect_raises(Rod::NoShadowRootError) { no_shadow.shadow_root }

      page.must_close
    end
  end

  it "matches TestUseReleasedElement behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      btn = page.must_element("button")
      btn.must_release
      expect_raises(Exception) { btn.click("left", 1) }

      btn = page.must_element("button")
      page.release(btn.object)
      expect_raises(Exception) { btn.click("left", 1) }

      page.must_close
    end
  end

  it "matches TestElementEWithDepth behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("describe.html"))
      page.must_wait_load

      ul_dom_node = page.must_element("ul").describe(-1, true)
      ul_dom_node.to_json.should contain("green tea")

      page.must_close
    end
  end

  it "matches TestElementOthers behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("input.html"))
      page.must_wait_load

      form = page.must_element("form")
      form.must_focus
      form.must_scroll_into_view
      form.must_element("[type=submit]").must_text.should eq("submit")
      form.must_element("[type=submit]").must_html.should eq("<input type=\"submit\" value=\"submit\">")
      form.must_wait("() => true")
      form.must_element_by_js("() => this").must_describe.local_name.should eq("form")
      form.must_elements_by_js("() => []").size.should eq(0)

      page.must_close
    end
  end

  it "matches TestWaitStable/TestWaitStableRAP behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("wait-stable.html"))
      page.must_wait_load

      el = page.must_element("button")

      start = Time.instant
      spawn do
        sleep 1.second
        el.must_eval("() => this.classList.remove('play')")
      end
      el.must_wait_stable
      (Time.instant - start).should be > 800.milliseconds

      el = page.must_element("button")
      el.must_eval("() => this.classList.add('play')")
      start = Time.instant
      spawn do
        sleep 1.second
        el.must_eval("() => this.classList.remove('play')")
      end
      el.wait_stable_raf
      (Time.instant - start).should be > 800.milliseconds

      page.must_close
    end
  end

  it "matches TestSearchIframes and TestSearchIframesAfterReload with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click-iframes.html"))
      page.must_wait_load

      el = page.must_search("button[onclick]")
      el.must_text.should eq("click me")
      el.must_click.must_matches("[a=ok]").should be_true

      frame = page.must_element("iframe").must_frame.must_element("iframe").must_frame
      frame.must_reload

      el = page.must_search("button[onclick]")
      el.must_text.should eq("click me")
      el.must_click.must_matches("[a=ok]").should be_true

      page.must_close
    end
  end

  it "matches TestIframes behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click-iframes.html"))
      page.must_wait_load

      frame01 = page.must_element("iframe").must_frame
      frame02 = frame01.must_element("iframe").must_frame
      frame02.must_element("button").must_click

      frame01.must_eval("() => testIsolation()").as_s.should eq("ok")
      frame02.must_has("[a=ok]").should be_true

      page.must_close
    end
  end

  it "matches TestShapeInIframe behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click-iframe.html"))
      page.must_wait_load

      pt = Rod::Lib::Quad.one_point_inside(
        page.must_element("iframe").must_frame.must_element("button").shape.quads
      ).not_nil!

      (pt.x - 238.0).abs.should be < 3.0
      (pt.y - 287.0).abs.should be < 3.0

      page.must_close
    end
  end

  it "matches TestIframeCrossDomains behavior with real browser" do
    r1_addr : Socket::IPAddress? = nil

    r1 = HTTP::Server.new do |ctx|
      if ctx.request.path == "/iframe"
        ctx.response.content_type = "text/html"
        ctx.response.print("<html><div id='a'>a</div></html>")
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
      end
    end

    r2 = HTTP::Server.new do |ctx|
      if ctx.request.path == "/page"
        src = "http://localhost:#{r1_addr.not_nil!.port}/iframe"
        ctx.response.content_type = "text/html"
        ctx.response.print("<html><iframe sandbox src='#{src}'></iframe></html>")
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
      end
    end

    r1_addr = r1.bind_tcp("localhost", 0)
    r2_addr = r2.bind_tcp("127.0.0.1", 0)
    spawn { r1.listen }
    spawn { r2.listen }

    begin
      with_live_browser do |browser|
        page = browser.must_page("http://127.0.0.1:#{r2_addr.port}/page")
        page.must_wait_load

        page.must_element("iframe").must_frame.must_element("#a").must_text.should eq("a")

        page.must_close
      end
    ensure
      r1.close
      r2.close
    end
  end

  it "matches TestPageRaceSearchCrossIframe with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("iframe.html"))
      page.must_wait_load

      race = page.race
      race.element("not exist").handle { |_| raise "element not exist" }
      race.search("span").handle(&.must_text.should(eq("01")))
      race.do

      page.must_close
    end
  end

  it "matches TestPageRaceRetryInHandle with real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("selector.html"))
      page.must_wait_load

      page.race.element("div").handle do |e|
        spawn do
          sleep 500.milliseconds
          e.must_element("button").must_eval("() => this.innerText = '04'")
        end
        e.must_element("button").must_wait("() => this.innerText === '04'")
      end.do

      page.must_close
    end
  end

  it "matches TestPageConsoleLog behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      wait = browser.context(page.get_context).wait_event_typed(Cdp::Runtime::ConsoleAPICalledEvent, page.get_session_id)
      page.must_eval("() => console.log(1, {b: ['test']})")
      event = wait.call

      page.must_object_to_json(event.args[1])["b"][0].as_s.should eq("test")
      all = page.must_objects_to_json(event.args).as_a
      all[0].as_i.should eq(1)
      all[1]["b"][0].as_s.should eq("test")

      page.must_close
    end
  end

  it "matches TestBlockingNavigation behavior with real browser" do
    pause = Channel(Nil).new
    unblock = Channel(Nil).new

    server = HTTP::Server.new do |ctx|
      case ctx.request.path
      when "/a"
        pause.send(nil)
        unblock.receive
      when "/b"
        ctx.response.content_type = "text/html"
        ctx.response.print("<html>ok</html>")
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
      end
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      with_live_browser do |browser|
        blocked = browser.must_page("about:blank")
        blocked_error = Channel(Exception?).new(1)

        spawn do
          begin
            blocked.timeout(800.milliseconds).must_navigate("http://127.0.0.1:#{addr.port}/a")
            blocked_error.send(nil)
          rescue ex
            blocked_error.send(ex)
          end
        end

        pause.receive
        ok_page = browser.must_page("http://127.0.0.1:#{addr.port}/b")
        ok_page.must_wait_load
        ok_page.must_element("html").must_text.should contain("ok")

        unblock.send(nil)
        blocked_error.receive

        blocked.must_close
        ok_page.must_close
      end
    ensure
      server.close
    end
  end

  it "matches TestResolveBlocking behavior with real browser" do
    unblock = Channel(Nil).new

    server = HTTP::Server.new do |ctx|
      if ctx.request.path == "/"
        unblock.receive
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
      end
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      with_live_browser do |browser|
        page = browser.must_page("about:blank")

        spawn do
          sleep 100.milliseconds
          page.must_stop_loading
        end

        expect_raises(Exception) do
          page.must_navigate("http://127.0.0.1:#{addr.port}/")
        end

        unblock.send(nil)
        page.must_close
      end
    ensure
      server.close
    end
  end

  it "matches TestPageActionAfterClose behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load
      page.must_close

      expect_raises(Rod::ContextCanceledError) do
        page.element("not-exists")
      end

      page = browser.must_page("about:blank")
      page.must_wait_load

      spawn do
        sleep 1.second
        page.must_close
      end

      expect_raises(Rod::ContextCanceledError) do
        page.eval("() => new Promise(() => {})")
      end
    end
  end

  it "matches TestPageWaitRequestIdle behavior with real browser" do
    sleep_time = 2.seconds
    log_io = IO::Memory.new
    logger_name = "rod-live-wait-request-idle"
    Log.setup(logger_name, :info, Log::IOBackend.new(log_io))

    server = HTTP::Server.new do |ctx|
      case ctx.request.path
      when "/r1", "/r4"
        ctx.response.content_type = "text/plain"
        ctx.response.print("ok")
      when "/r2"
        ctx.response.content_type = "text/plain"
        ctx.response.print("part")
        sleep sleep_time
      when "/r3"
        ctx.response.status = HTTP::Status::FOUND
        ctx.response.headers["Location"] = "/r4"
      when "/img.jpg"
        ctx.response.content_type = "image/jpeg"
        ctx.response.print("img")
      when "/"
        ctx.response.content_type = "text/html"
        ctx.response.print("<html><body></body></html>")
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
      end
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      with_live_browser do |browser|
        browser.logger(Log.for(logger_name))

        page = browser.must_page("http://127.0.0.1:#{addr.port}/")
        page.must_wait_load

        code = <<-JS
          () => {
            fetch('/r2').then(r => r.text())
            fetch('/r1')
            fetch('/r3')
            document.body.innerHTML = '<img src="/img.jpg" />'
          }
        JS

        browser.trace(true)
        wait = page.must_wait_request_idle(["/r1"])
        browser.trace(false)

        page.must_eval(code)
        started = Time.instant
        wait.call
        elapsed = Time.instant - started
        elapsed.should be > 1.5.seconds

        logs = log_io.to_s
        logs.should contain("[wait requests]")
        logs.should contain("/r2")

        wait = page.must_wait_request_idle(["/r2"])
        page.must_eval(code)
        started = Time.instant
        wait.call
        elapsed = Time.instant - started
        elapsed.should be < 1.5.seconds

        expect_raises(Exception) do
          wait.call
        end

        page.must_close
      end
    ensure
      server.close
    end
  end

  it "matches TestPageTriggerFavicon headless-network behavior with real browser" do
    server = HTTP::Server.new do |ctx|
      case ctx.request.path
      when "/test"
        ctx.response.content_type = "text/html"
        ctx.response.print("<html><head></head><body>ok</body></html>")
      when "/favicon.ico"
        ctx.response.content_type = "image/png"
        ctx.response.print("icon")
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
      end
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      with_live_browser do |browser|
        page = browser.must_page("http://127.0.0.1:#{addr.port}/test")
        page.must_wait_idle

        seen_favicon = false
        wait = browser.context(page.get_context).each_event(page.get_session_id, {
          Cdp::Network::RequestWillBeSentEvent.proto_event => Rod::Browser::CallbackInfo.new(
            Cdp::Network::RequestWillBeSentEvent,
            ->(event : Cdp::Event, _session_id : Rod::SessionID?) do
              req = event.as(Cdp::Network::RequestWillBeSentEvent)
              if req.request.url.ends_with?("/favicon.ico")
                seen_favicon = true
                true
              else
                nil
              end
            end
          ),
        })

        page.must_trigger_favicon
        wait.call

        seen_favicon.should be_true
        page.must_close
      end
    ensure
      server.close
    end
  end

  it "matches TestPageNavigateErr behavior with real browser" do
    server = HTTP::Server.new do |ctx|
      case ctx.request.path
      when "/404"
        ctx.response.status = HTTP::Status::NOT_FOUND
      when "/500"
        ctx.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
      else
        ctx.response.status = HTTP::Status::OK
        ctx.response.print("ok")
      end
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      with_live_browser do |browser|
        page = browser.must_page("about:blank")

        ex = expect_raises(Rod::NavigationError) do
          page.must_navigate("http://127.0.0.1:#{addr.port}/404")
        end
        ex.message.to_s.should contain("ERR_HTTP_RESPONSE_CODE_FAILURE")

        ex = expect_raises(Rod::NavigationError) do
          page.must_navigate("http://127.0.0.1:#{addr.port}/500")
        end
        ex.message.to_s.should contain("ERR_HTTP_RESPONSE_CODE_FAILURE")

        page.must_close
      end
    ensure
      server.close
    end
  end

  it "matches TestBrowserCrash behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      js = "() => new Promise(r => setTimeout(r, 10000))"

      eval_done = Channel(Exception?).new(1)
      spawn do
        begin
          page.must_eval(js)
          eval_done.send(nil)
        rescue ex
          eval_done.send(ex)
        end
      end

      sleep 200.milliseconds
      begin
        Cdp::Browser::Crash.new.call(browser)
      rescue
      end

      sleep 300.milliseconds

      expect_raises(Exception) do
        page.eval(js)
      end

      interrupted = false
      select
      when eval_done.receive?
        interrupted = true
      when timeout(2.seconds)
      end
      interrupted.should be_true
    end
  end

  it "matches TestBrowserLostConnection behavior with real browser" do
    launcher = Rod::Lib::Launcher::Launcher.new
      .bin(CHROME_BIN)
      .headless(true)
      .no_sandbox(true)
      .leakless(false)

    browser = Rod::Browser.new.control_url(launcher.launch)
    browser.connect

    begin
      page = browser.must_page("about:blank")

      spawn do
        sleep 1.second
        begin
          launcher.kill
        rescue
        end
      end

      expect_raises(Exception) do
        page.eval("() => new Promise(r => {})")
      end
    ensure
      begin
        browser.close
      rescue
      end
      begin
        launcher.kill
      rescue
      end
    end
  end

  it "matches TestElementTracing behavior with real browser" do
    with_live_browser do |browser|
      browser.trace(true)
      browser.logger(Log.for("rod-live-trace-quiet"))

      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      page.must_element("html").must_element("code").must_text.should eq(%(rod.element("code") html))

      browser.trace(false)
      page.must_close
    end
  end

  it "matches TestTrace behavior with real browser" do
    with_live_browser do |browser|
      seen = [] of Array(String)
      browser.logger(Rod::Lib::Utils.log { |list| seen << list })
      browser.trace(true)
      browser.slow_motion(1.microsecond)

      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      seen.any?(&.join(" ").includes?("[wait]")).should be_true

      page.must_element("button").must_click
      seen.any?(&.join(" ").includes?("[input] left click")).should be_true

      page.must_close
      browser.trace(false)
    end
  end

  it "matches TestTraceLogs behavior with real browser" do
    with_live_browser do |browser|
      browser.logger(Rod::Lib::Utils.logger_quiet)
      browser.trace(true)

      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load
      page.must_element("button").must_click

      # Go parity: overlay should not panic when runtime call path errors.
      page.must_close
      page.overlay(0.0, 0.0, 100.0, 30.0, "")

      browser.trace(false)
    end
  end

  it "matches TestMonitor behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      scoped, cancel = browser.with_cancel
      begin
        host = scoped.serve_monitor("")

        monitor_page = browser.must_page(host)
        monitor_page.must_wait_load
        link = monitor_page.must_element("#targets a")
        parent = link.parent
        raise "monitor target link has no parent" unless parent
        parent.html.should contain(page.target_id.value)

        monitor_page.must_navigate("#{host}/page/#{page.target_id.value}")
        monitor_page.must_wait("(id) => document.title.includes(id)", [JSON::Any.new(page.target_id.value)])

        img = HTTP::Client.get("#{host}/screenshot").body
        img.bytesize.should be > 10

        res = HTTP::Client.get("#{host}/api/page/test")
        res.status_code.should eq(400)
        JSON.parse(res.body)["code"].as_i.should eq(-32602)

        monitor_page.must_close
      ensure
        cancel.call
      end

      page.must_close
    end
  end

  it "matches TestMonitorErr behavior with real browser launcher url" do
    launcher = Rod::Lib::Launcher::Launcher.new
      .bin(CHROME_BIN)
      .headless(true)
      .no_sandbox(true)
      .leakless(false)

    ws_url = launcher.launch

    begin
      browser = Rod::Browser.new.monitor("abc").control_url(ws_url)
      expect_raises(ArgumentError, /invalid host format/) do
        browser.must_connect
      end
    ensure
      begin
        launcher.kill
      rescue
      end
    end
  end

  it "matches TestHijackMockWholeResponse behavior with real browser" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load

      router = page.hijack_requests
      begin
        router.add("http://localhost*", Cdp::Network::ResourceTypeDocument, ->(ctx : Rod::Hijack) do
          ctx.response.set_header("Content-Type", "text/html; charset=utf-8")
          ctx.response.set_body("<body>ok</body>")
          nil
        end)

        spawn { router.run }

        page.must_navigate("http://localhost")
        page.must_element("body").must_text.should eq("ok")
      ensure
        begin
          router.stop
        rescue
        end
        begin
          page.must_close
        rescue
        end
      end
    end
  end

  it "covers core TestHijack behavior with real browser and backend server" do
    server = nil.as(HTTP::Server?)
    fixture = File.read(File.expand_path("vendor/rod/fixtures/fetch.html", Dir.current))
    server = HTTP::Server.new do |ctx|
      case ctx.request.path
      when "/"
        ctx.response.content_type = "text/html; charset=utf-8"
        ctx.response.print(fixture)
      when "/a"
        ctx.request.method.should eq("POST")
        ctx.request.headers["Test"]?.should eq("header")
        body = ctx.request.body.try(&.gets_to_end) || ""
        body.should eq("a")

        ctx.response.content_type = "application/json"
        ctx.response.print(%({"text":"test"}))
      when "/b"
        ctx.response.content_type = "text/plain; charset=utf-8"
        ctx.response.print("b")
      else
        ctx.response.status_code = 404
      end
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }
    base = "http://127.0.0.1:#{addr.port}"

    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_wait_load
      router = page.hijack_requests
      client = HTTP::Client.new("127.0.0.1", addr.port)

      begin
        router.add("#{base}/a", Cdp::Network::ResourceTypeXHR, ->(ctx : Rod::Hijack) do
          req = ctx.request
          req.req.headers["Test"] = "header"
          req.set_body("test")
          req.set_body(123)
          req.set_body(req.body)

          req.method.should eq("POST")
          req.url.to_s.should eq("#{base}/a")
          req.type.should eq(Cdp::Network::ResourceTypeXHR)
          req.navigation?.should be_false
          req.header("Origin").should contain(base)

          ctx.load_response(client, true)
          ctx.response.payload.response_code.should eq(200)
          ctx.response.payload.response_code = 201

          ctx.response.add_header("Set-Cookie", "key=val1; Path=/")
          ctx.response.set_header("Set-Cookie", "key=val; Path=/")
          ctx.response.set_body({"text" => "test"})
          ctx.response.body.should eq(%({"text":"test"}))
          nil
        end)

        router.add("#{base}/b", Cdp::Network::ResourceTypeXHR, ->(ctx : Rod::Hijack) do
          ctx.load_response(client, true)
          nil
        end)

        spawn { router.run }

        page.must_navigate(base)
        page.must_element("#a").must_text.should eq("201 test key=val")
        page.must_element("#b").must_text.should eq("b")
      ensure
        begin
          router.stop
        rescue
        end
        client.close
        begin
          page.must_close
        rescue
        end
      end
    end
  ensure
    server.try(&.close)
  end

  it "matches TestFonts behavior with real browser" do
    unless Rod::Lib::Launcher.in_container?
      # Go parity gate: upstream only exercises this in containers.
      true.should be_true
      next
    end

    with_live_browser do |browser|
      page = browser.must_page(fixture_url("fonts.html"))
      page.must_wait_load
      page.must_pdf(File.join("tmp", "fonts.pdf"))
      page.must_close
    end
  end
end
