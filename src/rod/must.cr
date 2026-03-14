require "./browser"
require "./page"
require "./element"
require "file_utils"

module Rod
  enum SaveFileType
    Screenshot
    PDF
  end

  module SaveFileHelpers
    private def save_file(file_type : SaveFileType, bin : Bytes, to_file : String?) : Nil
      return if to_file.nil?

      output = if to_file.empty?
                 stamp = Time.utc.to_unix_ns.to_s
                 case file_type
                 in .screenshot?
                   File.join("tmp", "screenshots", "#{stamp}.png")
                 in .pdf?
                   File.join("tmp", "pdf", "#{stamp}.pdf")
                 end
               else
                 to_file
               end

      FileUtils.mkdir_p(File.dirname(output))
      File.write(output, bin)
    end
  end

  class Browser < ::Cdp::Client
    private def must_try(&block : -> T) : T forall T
      begin
        block.call
      rescue ex
        e(ex)
        raise ex
      end
    end

    # `foo!` aliases to `must_foo` (for example `page!` -> `must_page`).
    # This mirrors Go Rod's Must ergonomics while keeping Crystal call sites concise.
    macro method_missing(call)
      {% name = call.name.stringify %}
      {% if name.ends_with?("!") %}
        {{("must_" + name[0...-1]).id}}({{call.args.splat}})
      {% else %}
        {% raise "undefined method '#{name}' for #{@type}" %}
      {% end %}
    end

    # MustConnect is similar to connect.
    def must_connect : Browser
      must_try { connect }
      self
    end

    # MustClose is similar to close.
    def must_close : Nil
      must_try { close }
    end

    # MustIncognito is similar to incognito.
    def must_incognito : Browser
      must_try { incognito }
    end

    # MustPage is similar to page.
    # The url list will be joined by "/".
    def must_page(url : String = "about:blank") : Page
      must_try { page(url) }
    end

    # MustPages is similar to pages.
    def must_pages : Pages
      must_try { pages }
    end

    # MustPageFromTargetID is similar to page_from_target.
    def must_page_from_target_id(target_id : TargetID) : Page
      must_try { page_from_target(target_id) }
    end

    # MustHandleAuth is similar to handle_auth.
    def must_handle_auth(username : String, password : String) : Proc(Nil)
      w = must_try { handle_auth(username, password) }
      -> { must_try { w.call } }
    end

    # MustIgnoreCertErrors is similar to ignore_cert_errors.
    def must_ignore_cert_errors(enable : Bool) : Browser
      must_try { ignore_cert_errors(enable) }
      self
    end

    # MustGetCookies is similar to get_cookies.
    def must_get_cookies : Array(::Cdp::Network::Cookie)
      must_try { get_cookies }
    end

    # MustSetCookies is similar to set_cookies.
    # If the len(cookies) is 0 it will clear all the cookies.
    def must_set_cookies(cookies : Array(::Cdp::Network::Cookie) = [] of ::Cdp::Network::Cookie) : Browser
      if cookies.empty?
        must_try { set_cookies(nil) }
      else
        must_try { set_cookies(cookies) }
      end
      self
    end

    # MustWaitDownload is similar to wait_download.
    # It will read the file into bytes then remove the file.
    def must_wait_download : Proc(Array(UInt8))
      tmp_dir = File.join(Dir.tempdir, "rod", "downloads")
      wait = must_try { wait_download(tmp_dir) }

      -> {
        info = must_try { wait.call }
        path = File.join(tmp_dir, info.guid)
        begin
          data = File.read(path)
        ensure
          File.delete(path) rescue nil
        end
        data
      }
    end

    # MustVersion is similar to version.
    def must_version : ::Cdp::Browser::GetVersionResult
      must_try { version }
    end
  end

  struct Pages
    # MustFind is similar to find.
    def must_find(selector : String) : Page
      page = find(selector)
      raise PageNotFoundError.new unless page
      page
    end

    # MustFindByURL is similar to find_by_url.
    def must_find_by_url(regex : String) : Page
      page = find_by_url(regex)
      raise PageNotFoundError.new unless page
      page
    end
  end

  class Page
    include SaveFileHelpers

    private def must_try(&block : -> T) : T forall T
      begin
        block.call
      rescue ex
        e(ex)
        raise ex
      end
    end

    # `foo!` aliases to `must_foo` (for example `element!` -> `must_element`).
    # This keeps bang calls behaviorally equivalent to explicit `must_*` calls.
    macro method_missing(call)
      {% name = call.name.stringify %}
      {% if name.ends_with?("!") %}
        {{("must_" + name[0...-1]).id}}({{call.args.splat}})
      {% else %}
        {% raise "undefined method '#{name}' for #{@type}" %}
      {% end %}
    end

    # MustInfo is similar to info.
    def must_info : ::Cdp::Target::TargetInfo
      must_try { info }
    end

    # MustHTML is similar to html.
    def must_html : String
      must_try { html }
    end

    # MustCookies is similar to cookies.
    def must_cookies(urls : Array(String) = [] of String) : Array(::Cdp::Network::Cookie)
      must_try { cookies(urls) }
    end

    # MustSetCookies is similar to set_cookies.
    # If the len(cookies) is 0 it will clear all the cookies.
    def must_set_cookies(cookies : Array(::Cdp::Network::CookieParam) = [] of ::Cdp::Network::CookieParam) : Page
      if cookies.empty?
        must_try { set_cookies(nil) }
      else
        must_try { set_cookies(cookies) }
      end
      self
    end

    # MustSetExtraHeaders is similar to set_extra_headers.
    def must_set_extra_headers(dict : Array(String)) : Proc(Nil)
      cleanup = must_try { set_extra_headers(dict) }
      -> { must_try { cleanup.call } }
    end

    # MustSetUserAgent is similar to set_user_agent.
    def must_set_user_agent(req : ::Cdp::Emulation::SetUserAgentOverride) : Page
      must_try { set_user_agent(req) }
      self
    end

    # MustSetBlockedURLs is similar to set_blocked_urls.
    def must_set_blocked_urls(urls : Array(String)) : Page
      must_try { set_blocked_urls(urls) }
      self
    end

    # MustNavigate is similar to navigate.
    def must_navigate(url : String) : Page
      must_try { navigate(url) }
      self
    end

    # MustResetNavigationHistory is similar to reset_navigation_history.
    def must_reset_navigation_history : Page
      must_try { reset_navigation_history }
      self
    end

    # MustReload is similar to reload.
    def must_reload : Page
      must_try { reload }
      self
    end

    # MustActivate is similar to activate.
    def must_activate : Page
      must_try { activate }
      self
    end

    # MustNavigateBack is similar to navigate_back.
    def must_navigate_back : Page
      must_try { navigate_back }
      self
    end

    # MustNavigateForward is similar to navigate_forward.
    def must_navigate_forward : Page
      must_try { navigate_forward }
      self
    end

    # MustGetWindow is similar to get_window.
    def must_get_window : ::Cdp::Browser::Bounds
      must_try { get_window }
    end

    # MustSetWindow is similar to set_window.
    def must_set_window(left : Int32, top : Int32, width : Int32, height : Int32) : Page
      must_try do
        set_window(::Cdp::Browser::Bounds.new(
          left: left,
          top: top,
          width: width,
          height: height,
          window_state: ::Cdp::Browser::WindowStateNormal
        ))
      end
      self
    end

    # MustWindowMinimize is similar to window_minimize.
    def must_window_minimize : Page
      must_try do
        set_window(::Cdp::Browser::Bounds.new(
          window_state: ::Cdp::Browser::WindowStateMinimized
        ))
      end
      self
    end

    # MustWindowMaximize is similar to window_maximize.
    def must_window_maximize : Page
      must_try do
        set_window(::Cdp::Browser::Bounds.new(
          window_state: ::Cdp::Browser::WindowStateMaximized
        ))
      end
      self
    end

    # MustWindowFullscreen is similar to window_fullscreen.
    def must_window_fullscreen : Page
      must_try do
        set_window(::Cdp::Browser::Bounds.new(
          window_state: ::Cdp::Browser::WindowStateFullscreen
        ))
      end
      self
    end

    # MustWindowNormal is similar to window_normal.
    def must_window_normal : Page
      must_try do
        set_window(::Cdp::Browser::Bounds.new(
          window_state: ::Cdp::Browser::WindowStateNormal
        ))
      end
      self
    end

    # MustSetViewport is similar to set_viewport.
    def must_set_viewport(width : Int32, height : Int32, device_scale_factor : Float64, mobile : Bool) : Page
      must_try do
        set_viewport(::Cdp::Emulation::SetDeviceMetricsOverride.new(
          width: width.to_i64,
          height: height.to_i64,
          device_scale_factor: device_scale_factor,
          mobile: mobile,
          scale: nil,
          screen_width: nil,
          screen_height: nil,
          position_x: nil,
          position_y: nil,
          dont_set_visible_size: nil,
          screen_orientation: nil,
          viewport: nil,
          display_feature: nil,
          device_posture: nil
        ))
      end
      self
    end

    # Accept integer/other numeric scale factors and normalize to Float64.
    def must_set_viewport(width : Int32, height : Int32, device_scale_factor : Number, mobile : Bool) : Page
      must_set_viewport(width, height, device_scale_factor.to_f64, mobile)
    end

    # MustEmulate is similar to emulate.
    def must_emulate(device : Rod::Util::Devices::Device) : Page
      must_try { emulate(device) }
      self
    end

    # MustStopLoading is similar to stop_loading.
    def must_stop_loading : Page
      must_try { stop_loading }
      self
    end

    # MustClose is similar to close.
    def must_close : Nil
      must_try { close }
    end

    # MustHandleDialog is similar to handle_dialog.
    def must_handle_dialog : {Proc(::Cdp::Page::JavascriptDialogOpeningEvent), Proc(Bool, String, Nil)}
      w, h = must_try { handle_dialog }
      {w, ->(accept : Bool, prompt_text : String) {
        must_try do
          h.call(::Cdp::Page::HandleJavaScriptDialog.new(
            accept: accept,
            prompt_text: prompt_text
          ))
        end
      }}
    end

    # MustHandleFileDialog is similar to handle_file_dialog.
    def must_handle_file_dialog : Proc(Array(String), Nil)
      set_files = must_try { handle_file_dialog }
      ->(paths : Array(String)) { must_try { set_files.call(paths) } }
    end

    # MustScreenshot is similar to screenshot.
    # If the toFile is "", it will save output to "tmp/screenshots" folder, time as the file name.
    def must_screenshot(to_file : String? = nil) : Bytes
      bin = must_try { screenshot(false, nil) }
      must_try { save_file(SaveFileType::Screenshot, bin, to_file) }
      bin
    end

    # MustCaptureDOMSnapshot is similar to capture_dom_snapshot.
    def must_capture_dom_snapshot : ::Cdp::DOMSnapshot::CaptureSnapshotResult
      must_try { capture_dom_snapshot }
    end

    # MustTriggerFavicon is similar to trigger_favicon.
    def must_trigger_favicon : Page
      must_try { trigger_favicon }
      self
    end

    # MustScreenshotFullPage is similar to screenshot_full_page.
    # If the toFile is "", it will save output to "tmp/screenshots" folder, time as the file name.
    def must_screenshot_full_page(to_file : String? = nil) : Bytes
      bin = must_try { screenshot(true, nil) }
      must_try { save_file(SaveFileType::Screenshot, bin, to_file) }
      bin
    end

    # MustScrollScreenshot is similar to scroll_screenshot.
    # If the toFile is "", it will save output to "tmp/screenshots" folder, time as the file name.
    def must_scroll_screenshot(to_file : String? = nil) : Bytes
      bin = must_try { scroll_screenshot(nil) }
      must_try { save_file(SaveFileType::Screenshot, bin, to_file) }
      bin
    end

    # MustPDF is similar to pdf.
    # If the toFile is "", it will save output to "tmp/pdf" folder, time as the file name.
    def must_pdf(to_file : String? = nil) : Bytes
      r = must_try { pdf(::Cdp::Page::PrintToPDF.new) }
      begin
        bin = IO::Memory.new.tap { |io| IO.copy(r, io) }.to_slice
      ensure
        r.close if r.responds_to?(:close)
      end
      must_try { save_file(SaveFileType::PDF, bin, to_file) }
      bin
    end

    # MustWaitOpen is similar to wait_open.
    def must_wait_open : Proc(Page)
      w = wait_open
      -> do
        begin
          w.call
        rescue ex
          e(ex)
          raise ex
        end
      end
    end

    # MustWaitNavigation is similar to wait_navigation.
    def must_wait_navigation(name : String = "networkAlmostIdle") : Proc(Nil)
      wait_navigation(name)
    end

    # MustWaitRequestIdle is similar to wait_request_idle.
    def must_wait_request_idle(excludes : Array(String) = [] of String) : Proc(Nil)
      wait_request_idle(300.milliseconds, nil, excludes, nil)
    end

    # MustWaitIdle is similar to wait_idle.
    def must_wait_idle : Page
      must_try { wait_idle(1.minute) }
      self
    end

    # MustWaitDOMStable is similar to wait_dom_stable.
    def must_wait_dom_stable : Page
      must_try { wait_dom_stable(1.second, 0) }
      self
    end

    # MustWaitStable is similar to wait_stable.
    def must_wait_stable : Page
      must_try { wait_stable(1.second) }
      self
    end

    # MustWaitLoad is similar to wait_load.
    def must_wait_load : Page
      must_try { wait_load }
      self
    end

    # MustAddScriptTag is similar to add_script_tag.
    def must_add_script_tag(url : String) : Page
      must_try { add_script_tag(url, "") }
      self
    end

    # MustAddStyleTag is similar to add_style_tag.
    def must_add_style_tag(url : String) : Page
      must_try { add_style_tag(url, "") }
      self
    end

    # MustEvalOnNewDocument is similar to eval_on_new_document.
    def must_eval_on_new_document(js : String) : Nil
      must_try { eval_on_new_document(js) }
    end

    # MustExpose is similar to expose.
    def must_expose(name : String, fn : Proc(::JSON::Any, ::JSON::Any)) : Proc(Nil)
      s = must_try { expose(name, fn) }
      -> { must_try { s.call } }
    end

    # MustEval is similar to eval.
    def must_eval(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : ::JSON::Any
      res = must_try { eval(js, params) }
      res.value || JSON::Any.new(nil)
    end

    # MustEvaluate is similar to evaluate.
    def must_evaluate(opts : EvalOptions) : ::Cdp::Runtime::RemoteObject
      must_try { evaluate(opts) }
    end

    # MustWait is similar to wait.
    def must_wait(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Page
      must_try { wait(EvalOptions.new(js, params)) }
      self
    end

    # MustWaitElementsMoreThan is similar to wait_elements_more_than.
    def must_wait_elements_more_than(selector : String, num : Int32) : Page
      must_try { wait_elements_more_than(selector, num) }
      self
    end

    # MustObjectToJSON is similar to object_to_json.
    def must_object_to_json(obj : ::Cdp::Runtime::RemoteObject) : ::JSON::Any
      must_try { object_to_json(obj) }
    end

    # MustObjectsToJSON is similar to objects_to_json.
    def must_objects_to_json(list : Array(::Cdp::Runtime::RemoteObject)) : ::JSON::Any
      arr = [] of ::JSON::Any
      list.each do |obj|
        j = must_try { object_to_json(obj) }
        arr << j
      end
      ::JSON::Any.new(arr)
    end

    # MustElementFromNode is similar to element_from_node.
    def must_element_from_node(node : ::Cdp::DOM::Node) : Element
      must_try { element_from_node(node) }
    end

    # MustElementFromPoint is similar to element_from_point.
    def must_element_from_point(left : Int32, top : Int32) : Element
      must_try { element_from_point(left, top) }
    end

    # MustRelease is similar to release.
    def must_release(obj : ::Cdp::Runtime::RemoteObject) : Page
      must_try { release(obj) }
      self
    end

    # MustHas is similar to has.
    def must_has(selector : String) : Bool
      has, _ = must_try { has(selector) }
      has
    end

    # MustHasX is similar to has_x.
    def must_has_x(selector : String) : Bool
      has, _ = must_try { has_x(selector) }
      has
    end

    # MustHasR is similar to has_r.
    def must_has_r(selector : String, regex : String) : Bool
      has, _ = must_try { has_r(selector, regex) }
      has
    end

    # MustSearch is similar to search.
    # It only returns the first element in the search result.
    def must_search(query : String) : Element
      res = must_try { search(query) }
      begin
        first = res.first
        raise ElementNotFoundError.new unless first
        first
      ensure
        res.release
      end
    end

    # MustElement finds one CSS match and raises when none are found.
    # It respects query timeout behavior from the underlying page context/options.
    def must_element(selector : String) : Element
      must_try { element(selector) }
    end

    # MustElementR finds one element by CSS + text regex and raises when none are found.
    # It respects query timeout behavior from the underlying page context/options.
    def must_element_r(selector : String, js_regex : String) : Element
      must_try { element_r(selector, js_regex) }
    end

    # MustElementX finds one XPath match and raises when none are found.
    # It respects query timeout behavior from the underlying page context/options.
    def must_element_x(x_path : String) : Element
      must_try { element_x(x_path) }
    end

    # MustElementByJS evaluates JS and expects a single DOM node result.
    # It raises when JS returns null/non-node or evaluation fails.
    def must_element_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Element
      must_try { element_by_js(EvalOptions.new(js, params)) }
    end

    # MustElements returns all CSS matches (empty list when none are found).
    def must_elements(selector : String) : Elements
      must_try { elements(selector) }
    end

    # MustElementsX returns all XPath matches (empty list when none are found).
    def must_elements_x(xpath : String) : Elements
      must_try { elements_x(xpath) }
    end

    # MustElementsByJS evaluates JS and expects an array of DOM nodes.
    # It raises when JS does not return an array.
    def must_elements_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Elements
      must_try { elements_by_js(EvalOptions.new(js, params)) }
    end

    # MustSetDocumentContent is similar to set_document_content.
    def must_set_document_content(html : String) : Page
      must_try { set_document_content(html) }
      self
    end
  end

  class Element
    include SaveFileHelpers

    private def must_try(&block : -> T) : T forall T
      begin
        block.call
      rescue ex
        e(ex)
        raise ex
      end
    end

    # `foo!` aliases to `must_foo` (for example `click!` -> `must_click`).
    # This keeps bang calls behaviorally equivalent to explicit `must_*` calls.
    macro method_missing(call)
      {% name = call.name.stringify %}
      {% if name.ends_with?("!") %}
        {{("must_" + name[0...-1]).id}}({{call.args.splat}})
      {% else %}
        {% raise "undefined method '#{name}' for #{@type}" %}
      {% end %}
    end

    # MustDescribe is similar to describe.
    def must_describe : ::Cdp::DOM::Node
      must_try { describe(1, false) }
    end

    # MustShadowRoot is similar to shadow_root.
    def must_shadow_root : Element
      must_try { shadow_root }
    end

    # MustFrame is similar to frame.
    def must_frame : Page
      must_try { frame }
    end

    # MustFocus is similar to focus.
    def must_focus : Element
      must_try { focus }
      self
    end

    # MustScrollIntoView is similar to scroll_into_view.
    def must_scroll_into_view : Element
      must_try { scroll_into_view }
      self
    end

    # MustHover is similar to hover.
    def must_hover : Element
      must_try { hover }
      self
    end

    # MustClick is similar to click.
    def must_click : Element
      must_try { click(::Cdp::Input::Left, 1) }
      self
    end

    # MustDoubleClick is similar to click.
    def must_double_click : Element
      must_try { click(::Cdp::Input::Left, 2) }
      self
    end

    # MustTap is similar to tap.
    def must_tap : Element
      must_try { tap }
      self
    end

    # MustInteractable is similar to interactable.
    def must_interactable : Bool
      must_try { interactable }
      true
    rescue ex : NotInteractableError
      false
    rescue ex
      e(ex)
      raise
    end

    # MustWaitInteractable is similar to wait_interactable.
    def must_wait_interactable : Element
      must_try { wait_interactable }
      self
    end

    # MustType is similar to type.
    def must_type(keys : Array(Input::Key)) : Element
      must_try do
        keys.each { |key| type(key) }
      end
      self
    end

    def must_type(*keys : Input::Key) : Element
      must_try { type(*keys) }
      self
    end

    # MustKeyActions is similar to key_actions.
    def must_key_actions : KeyActions
      must_try { key_actions }
    end

    # MustSelectText is similar to select_text.
    def must_select_text(regex : String) : Element
      must_try { select_text(regex) }
      self
    end

    # MustSelectAllText is similar to select_all_text.
    def must_select_all_text : Element
      must_try { select_all_text }
      self
    end

    # MustInput is similar to input.
    def must_input(text : String) : Element
      must_try { input(text) }
      self
    end

    # MustInputTime is similar to input.
    def must_input_time(t : Time) : Element
      must_try { input_time(t) }
      self
    end

    # MustInputColor is similar to input_color.
    def must_input_color(color : String) : Element
      must_try { input_color(color) }
      self
    end

    # MustBlur is similar to blur.
    def must_blur : Element
      must_try { blur }
      self
    end

    # MustSelect is similar to select.
    def must_select(*selectors : String) : Element
      begin
        self.select(selectors.to_a, true, SelectorType::Text)
      rescue ex
        self.e(ex)
        raise ex
      end
      self
    end

    # MustMatches is similar to matches.
    def must_matches(selector : String) : Bool
      must_try { matches(selector) }
    end

    # MustAttribute is similar to attribute.
    def must_attribute(name : String) : String?
      must_try { attribute(name) }
    end

    # MustProperty is similar to property.
    def must_property(name : String) : ::JSON::Any
      must_try { property(name) }
    end

    # MustDisabled is similar to disabled.
    def must_disabled : Bool
      must_try { disabled }
    end

    # MustContainsElement is similar to contains_element.
    def must_contains_element(target : Element) : Bool
      must_try { contains_element(target) }
    end

    # MustSetFiles is similar to set_files.
    def must_set_files(paths : Array(String)) : Element
      must_try { set_files(paths) }
      self
    end

    # MustText is similar to text.
    def must_text : String
      must_try { text }
    end

    # MustHTML is similar to html.
    def must_html : String
      must_try { html }
    end

    # MustVisible is similar to visible.
    def must_visible : Bool
      must_try { visible }
    end

    # MustWaitLoad is similar to wait_load.
    def must_wait_load : Element
      must_try { wait_load }
      self
    end

    # MustWaitStable is similar to wait_stable.
    def must_wait_stable : Element
      must_try { wait_stable(300.milliseconds) }
      self
    end

    # MustWait is similar to wait.
    def must_wait(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Element
      must_try { wait(EvalOptions.new(js, params)) }
      self
    end

    # MustWaitVisible is similar to wait_visible.
    def must_wait_visible : Element
      must_try { wait_visible }
      self
    end

    # MustWaitInvisible is similar to wait_invisible.
    def must_wait_invisible : Element
      must_try { wait_invisible }
      self
    end

    # MustWaitEnabled is similar to wait_enabled.
    def must_wait_enabled : Element
      must_try { wait_enabled }
      self
    end

    # MustWaitWritable is similar to wait_writable.
    def must_wait_writable : Element
      must_try { wait_writable }
      self
    end

    # MustShape is similar to shape.
    def must_shape : ::Cdp::DOM::GetContentQuadsResult
      must_try { shape }
    end

    # MustCanvasToImage is similar to canvas_to_image.
    def must_canvas_to_image : Bytes
      must_try { canvas_to_image("", -1.0) }
    end

    # MustResource is similar to resource.
    def must_resource : Bytes
      must_try { resource }
    end

    # MustBackgroundImage is similar to background_image.
    def must_background_image : Bytes
      must_try { background_image }
    end

    # MustScreenshot is similar to screenshot.
    def must_screenshot(to_file : String? = nil) : Bytes
      bin = must_try { screenshot(::Cdp::Page::CaptureScreenshotFormatPng, 0) }
      must_try { save_file(SaveFileType::Screenshot, bin, to_file) }
      bin
    end

    # MustRelease is similar to release.
    def must_release : Nil
      must_try { release }
    end

    # MustRemove is similar to remove.
    def must_remove : Nil
      must_try { remove }
    end

    # MustEval is similar to eval.
    def must_eval(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : ::JSON::Any
      res = must_try { eval(js, params) }
      res.value || JSON::Any.new(nil)
    end

    # MustHas is similar to has.
    def must_has(selector : String) : Bool
      has, _ = must_try { has(selector) }
      has
    end

    # MustHasX is similar to has_x.
    def must_has_x(selector : String) : Bool
      has, _ = must_try { has_x(selector) }
      has
    end

    # MustHasR is similar to has_r.
    def must_has_r(selector : String, regex : String) : Bool
      has, _ = must_try { has_r(selector, regex) }
      has
    end

    # MustElement finds one descendant CSS match and raises when none are found.
    # It respects query timeout behavior from the underlying page context/options.
    def must_element(selector : String) : Element
      must_try { element(selector) }
    end

    # MustElementX finds one descendant XPath match and raises when none are found.
    # It respects query timeout behavior from the underlying page context/options.
    def must_element_x(xpath : String) : Element
      must_try { element_x(xpath) }
    end

    # MustElementByJS evaluates JS against this element and expects one DOM node.
    # It raises when JS returns null/non-node or evaluation fails.
    def must_element_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Element
      must_try { element_by_js(EvalOptions.new(js, params)) }
    end

    # MustParent is similar to parent.
    def must_parent : Element
      value = must_try { parent }
      raise ElementNotFoundError.new unless value
      value
    end

    # MustParents is similar to parents.
    def must_parents(selector : String) : Elements
      must_try { parents(selector) }
    end

    # MustNext is similar to next.
    def must_next : Element
      value = must_try { self.next }
      raise ElementNotFoundError.new unless value
      value
    end

    # MustPrevious is similar to previous.
    def must_previous : Element
      value = must_try { previous }
      raise ElementNotFoundError.new unless value
      value
    end

    # MustElementR finds one descendant by CSS + text regex and raises when none are found.
    # It respects query timeout behavior from the underlying page context/options.
    def must_element_r(selector : String, regex : String) : Element
      must_try { element_r(selector, regex) }
    end

    # MustElements returns all descendant CSS matches (empty list when none are found).
    def must_elements(selector : String) : Elements
      must_try { elements(selector) }
    end

    # MustElementsX returns all descendant XPath matches (empty list when none are found).
    def must_elements_x(xpath : String) : Elements
      must_try { elements_x(xpath) }
    end

    # MustElementsByJS evaluates JS against this element and expects an array of DOM nodes.
    # It raises when JS does not return an array.
    def must_elements_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Elements
      must_try { elements_by_js(EvalOptions.new(js, params)) }
    end

    # MustEqual is similar to equal.
    def must_equal(elm : Element) : Bool
      must_try { equal(elm) }
    end

    # MustMoveMouseOut is similar to move_mouse_out.
    def must_move_mouse_out : Element
      must_try { move_mouse_out }
      self
    end

    # MustGetXPath is similar to get_xpath.
    def must_get_xpath(optimized : Bool = false) : String
      must_try { get_xpath(optimized) }
    end
  end

  class Pool(T)
    # MustGet gets an element from the pool and raises if creation fails.
    def must_get(&create : -> T) : T
      elem, err = get { {create.call, nil} }
      Rod::Utils.e(err)
      raise "pool create returned nil element without error" unless elem
      elem
    end
  end
end
