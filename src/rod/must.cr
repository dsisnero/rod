require "./browser"
require "./page"
require "./element"

module Rod
  # Helper to wrap a method call with error handling.
  private macro must_wrap(call)
    begin
      {{call}}
    rescue ex
      e(ex)
      raise # e should have raised, but just in case
    end
  end

  class Browser < ::Cdp::Client
    # MustConnect is similar to connect.
    def must_connect : Browser
      must_wrap connect
      self
    end

    # MustClose is similar to close.
    def must_close : Nil
      must_wrap close
    end

    # MustIncognito is similar to incognito.
    def must_incognito : Browser
      must_wrap incognito
    end

    # MustPage is similar to page.
    # The url list will be joined by "/".
    def must_page(url : String = "about:blank") : Page
      must_wrap page(url)
    end

    # MustPages is similar to pages.
    def must_pages : Pages
      must_wrap pages
    end

    # MustPageFromTargetID is similar to page_from_target.
    def must_page_from_target_id(target_id : TargetID) : Page
      must_wrap page_from_target(target_id)
    end

    # MustHandleAuth is similar to handle_auth.
    def must_handle_auth(username : String, password : String) : Proc(Nil)
      w = must_wrap handle_auth(username, password)
      -> { must_wrap w.call }
    end

    # MustIgnoreCertErrors is similar to ignore_cert_errors.
    def must_ignore_cert_errors(enable : Bool) : Browser
      must_wrap ignore_cert_errors(enable)
      self
    end

    # MustGetCookies is similar to get_cookies.
    def must_get_cookies : Array(::Cdp::Network::Cookie)
      must_wrap get_cookies
    end

    # MustSetCookies is similar to set_cookies.
    # If the len(cookies) is 0 it will clear all the cookies.
    def must_set_cookies(cookies : Array(::Cdp::Network::Cookie) = [] of ::Cdp::Network::Cookie) : Browser
      if cookies.empty?
        must_wrap set_cookies(nil)
      else
        must_wrap set_cookies(cookies)
      end
      self
    end

    # MustWaitDownload is similar to wait_download.
    # It will read the file into bytes then remove the file.
    def must_wait_download : Proc(Array(UInt8))
      tmp_dir = File.join(Dir.tempdir, "rod", "downloads")
      wait = must_wrap wait_download(tmp_dir)

      -> {
        info = must_wrap wait.call
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
      must_wrap version
    end
  end

  # Pages is a type alias for Array(Page). Must helpers for Pages are defined as extension methods.
  # TODO: Implement Pages must helpers when Pages type is defined.
  # class Pages
  #   # MustFind is similar to find.
  #   def must_find(selector : String) : Page
  #     must_wrap find(selector)
  #   rescue ex
  #     if !empty?
  #       self[0].e(ex)
  #     else
  #       # fallback to utils.E
  #       ::Utils.e(ex)
  #     end
  #     raise
  #   end
  #
  #   # MustFindByURL is similar to find_by_url.
  #   def must_find_by_url(regex : String) : Page
  #     must_wrap find_by_url(regex)
  #   rescue ex
  #     if !empty?
  #       self[0].e(ex)
  #     else
  #       ::Utils.e(ex)
  #     end
  #     raise
  #   end
  # end

  class Page
    # MustInfo is similar to info.
    def must_info : ::Cdp::Target::TargetInfo
      must_wrap info
    end

    # MustHTML is similar to html.
    def must_html : String
      must_wrap html
    end

    # MustCookies is similar to cookies.
    def must_cookies(urls : Array(String) = [] of String) : Array(::Cdp::Network::Cookie)
      must_wrap cookies(urls)
    end

    # MustSetCookies is similar to set_cookies.
    # If the len(cookies) is 0 it will clear all the cookies.
    def must_set_cookies(cookies : Array(::Cdp::Network::CookieParam) = [] of ::Cdp::Network::CookieParam) : Page
      if cookies.empty?
        must_wrap set_cookies(nil)
      else
        must_wrap set_cookies(cookies)
      end
      self
    end

    # MustSetExtraHeaders is similar to set_extra_headers.
    def must_set_extra_headers(dict : Array(String)) : Proc(Nil)
      cleanup = must_wrap set_extra_headers(dict)
      -> { must_wrap cleanup.call }
    end

    # MustSetUserAgent is similar to set_user_agent.
    def must_set_user_agent(req : ::Cdp::Network::SetUserAgentOverride) : Page
      must_wrap set_user_agent(req)
      self
    end

    # MustSetBlockedURLs is similar to set_blocked_urls.
    def must_set_blocked_urls(urls : Array(String)) : Page
      must_wrap set_blocked_urls(urls)
      self
    end

    # MustNavigate is similar to navigate.
    def must_navigate(url : String) : Page
      must_wrap navigate(url)
      self
    end

    # MustResetNavigationHistory is similar to reset_navigation_history.
    def must_reset_navigation_history : Page
      must_wrap reset_navigation_history
      self
    end

    # MustReload is similar to reload.
    def must_reload : Page
      must_wrap reload
      self
    end

    # MustActivate is similar to activate.
    def must_activate : Page
      must_wrap activate
      self
    end

    # MustNavigateBack is similar to navigate_back.
    def must_navigate_back : Page
      must_wrap navigate_back
      self
    end

    # MustNavigateForward is similar to navigate_forward.
    def must_navigate_forward : Page
      must_wrap navigate_forward
      self
    end

    # MustGetWindow is similar to get_window.
    def must_get_window : ::Cdp::Browser::Bounds
      must_wrap get_window
    end

    # MustSetWindow is similar to set_window.
    def must_set_window(left : Int32, top : Int32, width : Int32, height : Int32) : Page
      must_wrap set_window(::Cdp::Browser::Bounds.new(
        left: left,
        top: top,
        width: width,
        height: height,
        window_state: ::Cdp::Browser::WindowState::Normal
      ))
      self
    end

    # MustWindowMinimize is similar to window_minimize.
    def must_window_minimize : Page
      must_wrap set_window(::Cdp::Browser::Bounds.new(
        window_state: ::Cdp::Browser::WindowState::Minimized
      ))
      self
    end

    # MustWindowMaximize is similar to window_maximize.
    def must_window_maximize : Page
      must_wrap set_window(::Cdp::Browser::Bounds.new(
        window_state: ::Cdp::Browser::WindowState::Maximized
      ))
      self
    end

    # MustWindowFullscreen is similar to window_fullscreen.
    def must_window_fullscreen : Page
      must_wrap set_window(::Cdp::Browser::Bounds.new(
        window_state: ::Cdp::Browser::WindowState::Fullscreen
      ))
      self
    end

    # MustWindowNormal is similar to window_normal.
    def must_window_normal : Page
      must_wrap set_window(::Cdp::Browser::Bounds.new(
        window_state: ::Cdp::Browser::WindowState::Normal
      ))
      self
    end

    # MustSetViewport is similar to set_viewport.
    def must_set_viewport(width : Int32, height : Int32, device_scale_factor : Float64, mobile : Bool) : Page
      must_wrap set_viewport(::Cdp::Emulation::SetDeviceMetricsOverride.new(
        width: width,
        height: height,
        device_scale_factor: device_scale_factor,
        mobile: mobile
      ))
      self
    end

    # MustEmulate is similar to emulate.
    def must_emulate(device : Devices::Device) : Page
      must_wrap emulate(device)
      self
    end

    # MustStopLoading is similar to stop_loading.
    def must_stop_loading : Page
      must_wrap stop_loading
      self
    end

    # MustClose is similar to close.
    def must_close : Nil
      must_wrap close
    end

    # MustHandleDialog is similar to handle_dialog.
    def must_handle_dialog : {Proc(::Cdp::Page::JavascriptDialogOpening), Proc(Bool, String, Nil)}
      w, h = must_wrap handle_dialog
      {w, ->(accept : Bool, prompt_text : String) {
        must_wrap h.call(::Cdp::Page::HandleJavaScriptDialog.new(
          accept: accept,
          prompt_text: prompt_text
        ))
      }}
    end

    # MustHandleFileDialog is similar to handle_file_dialog.
    def must_handle_file_dialog : Proc(Array(String), Nil)
      set_files = must_wrap handle_file_dialog
      ->(paths : Array(String)) { must_wrap set_files.call(paths) }
    end

    # MustScreenshot is similar to screenshot.
    # If the toFile is "", it will save output to "tmp/screenshots" folder, time as the file name.
    def must_screenshot(to_file : String? = nil) : Array(UInt8)
      bin = must_wrap screenshot(false, nil)
      must_wrap save_file(SaveFileType::Screenshot, bin, to_file)
      bin
    end

    # MustCaptureDOMSnapshot is similar to capture_dom_snapshot.
    def must_capture_dom_snapshot : ::Cdp::DOMSnapshot::CaptureSnapshotResult
      must_wrap capture_dom_snapshot
    end

    # MustTriggerFavicon is similar to trigger_favicon.
    def must_trigger_favicon : Page
      must_wrap trigger_favicon
      self
    end

    # MustScreenshotFullPage is similar to screenshot_full_page.
    # If the toFile is "", it will save output to "tmp/screenshots" folder, time as the file name.
    def must_screenshot_full_page(to_file : String? = nil) : Array(UInt8)
      bin = must_wrap screenshot(true, nil)
      must_wrap save_file(SaveFileType::Screenshot, bin, to_file)
      bin
    end

    # MustScrollScreenshot is similar to scroll_screenshot.
    # If the toFile is "", it will save output to "tmp/screenshots" folder, time as the file name.
    def must_scroll_screenshot(to_file : String? = nil) : Array(UInt8)
      bin = must_wrap scroll_screenshot(nil)
      must_wrap save_file(SaveFileType::Screenshot, bin, to_file)
      bin
    end

    # MustPDF is similar to pdf.
    # If the toFile is "", it will save output to "tmp/pdf" folder, time as the file name.
    def must_pdf(to_file : String? = nil) : Array(UInt8)
      r = must_wrap pdf(::Cdp::Page::PrintToPDF.new)
      begin
        bin = IO::Memory.new.tap { |io| IO.copy(r, io) }.to_slice
      ensure
        r.close if r.responds_to?(:close)
      end
      must_wrap save_file(SaveFileType::PDF, bin, to_file)
      bin
    end

    # MustWaitOpen is similar to wait_open.
    def must_wait_open : Proc(Page)
      w = wait_open
      -> {
        page = must_wrap w.call
        page
      }
    end

    # MustWaitNavigation is similar to wait_navigation.
    def must_wait_navigation : Proc(Nil)
      wait_navigation(::Cdp::Page::LifecycleEventName::NetworkAlmostIdle)
    end

    # MustWaitRequestIdle is similar to wait_request_idle.
    def must_wait_request_idle(excludes : Array(String) = [] of String) : Proc(Nil)
      wait_request_idle(300.milliseconds, nil, excludes, nil)
    end

    # MustWaitIdle is similar to wait_idle.
    def must_wait_idle : Page
      must_wrap wait_idle(1.minute)
      self
    end

    # MustWaitDOMStable is similar to wait_dom_stable.
    def must_wait_dom_stable : Page
      must_wrap wait_dom_stable(1.second, 0)
      self
    end

    # MustWaitStable is similar to wait_stable.
    def must_wait_stable : Page
      must_wrap wait_stable(1.second)
      self
    end

    # MustWaitLoad is similar to wait_load.
    def must_wait_load : Page
      must_wrap wait_load
      self
    end

    # MustAddScriptTag is similar to add_script_tag.
    def must_add_script_tag(url : String) : Page
      must_wrap add_script_tag(url, "")
      self
    end

    # MustAddStyleTag is similar to add_style_tag.
    def must_add_style_tag(url : String) : Page
      must_wrap add_style_tag(url, "")
      self
    end

    # MustEvalOnNewDocument is similar to eval_on_new_document.
    def must_eval_on_new_document(js : String) : Nil
      must_wrap eval_on_new_document(js)
    end

    # MustExpose is similar to expose.
    def must_expose(name : String, fn : Proc(::JSON::Any, ::JSON::Any)) : Proc(Nil)
      s = must_wrap expose(name, fn)
      -> { must_wrap s.call }
    end

    # MustEval is similar to eval.
    def must_eval(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : ::JSON::Any
      res = must_wrap eval(js, params)
      res.value
    end

    # MustEvaluate is similar to evaluate.
    def must_evaluate(opts : EvalOptions) : ::Cdp::Runtime::RemoteObject
      must_wrap evaluate(opts)
    end

    # MustWait is similar to wait.
    def must_wait(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Page
      must_wrap wait(EvalOptions.new(js, params))
      self
    end

    # MustWaitElementsMoreThan is similar to wait_elements_more_than.
    def must_wait_elements_more_than(selector : String, num : Int32) : Page
      must_wrap wait_elements_more_than(selector, num)
      self
    end

    # MustObjectToJSON is similar to object_to_json.
    def must_object_to_json(obj : ::Cdp::Runtime::RemoteObject) : ::JSON::Any
      must_wrap object_to_json(obj)
    end

    # MustObjectsToJSON is similar to objects_to_json.
    def must_objects_to_json(list : Array(::Cdp::Runtime::RemoteObject)) : ::JSON::Any
      arr = [] of ::JSON::Any
      list.each do |obj|
        j = must_wrap object_to_json(obj)
        arr << j
      end
      ::JSON::Any.new(arr)
    end

    # MustElementFromNode is similar to element_from_node.
    def must_element_from_node(node : ::Cdp::DOM::Node) : Element
      must_wrap element_from_node(node)
    end

    # MustElementFromPoint is similar to element_from_point.
    def must_element_from_point(left : Int32, top : Int32) : Element
      must_wrap element_from_point(left, top)
    end

    # MustRelease is similar to release.
    def must_release(obj : ::Cdp::Runtime::RemoteObject) : Page
      must_wrap release(obj)
      self
    end

    # MustHas is similar to has.
    def must_has(selector : String) : Bool
      has, _ = must_wrap has(selector)
      has
    end

    # MustHasX is similar to has_x.
    def must_has_x(selector : String) : Bool
      has, _ = must_wrap has_x(selector)
      has
    end

    # MustHasR is similar to has_r.
    def must_has_r(selector : String, regex : String) : Bool
      has, _ = must_wrap has_r(selector, regex)
      has
    end

    # MustSearch is similar to search.
    # It only returns the first element in the search result.
    def must_search(query : String) : Element
      res = must_wrap search(query)
      res.release
      res.first
    end

    # MustElement is similar to element.
    def must_element(selector : String) : Element
      must_wrap element(selector)
    end

    # MustElementR is similar to element_r.
    def must_element_r(selector : String, js_regex : String) : Element
      must_wrap element_r(selector, js_regex)
    end

    # MustElementX is similar to element_x.
    def must_element_x(x_path : String) : Element
      must_wrap element_x(x_path)
    end

    # MustElementByJS is similar to element_by_js.
    def must_element_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Element
      must_wrap element_by_js(EvalOptions.new(js, params))
    end

    # MustElements is similar to elements.
    def must_elements(selector : String) : Elements
      must_wrap elements(selector)
    end

    # MustElementsX is similar to elements_x.
    def must_elements_x(xpath : String) : Elements
      must_wrap elements_x(xpath)
    end

    # MustElementsByJS is similar to elements_by_js.
    def must_elements_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Elements
      must_wrap elements_by_js(EvalOptions.new(js, params))
    end

    # MustSetDocumentContent is similar to set_document_content.
    def must_set_document_content(html : String) : Page
      must_wrap set_document_content(html)
      self
    end
  end

  class Element
    # MustDescribe is similar to describe.
    def must_describe : ::Cdp::DOM::Node
      must_wrap describe(1, false)
    end

    # MustShadowRoot is similar to shadow_root.
    def must_shadow_root : Element
      must_wrap shadow_root
    end

    # MustFrame is similar to frame.
    def must_frame : Page
      must_wrap frame
    end

    # MustFocus is similar to focus.
    def must_focus : Element
      must_wrap focus
      self
    end

    # MustScrollIntoView is similar to scroll_into_view.
    def must_scroll_into_view : Element
      must_wrap scroll_into_view
      self
    end

    # MustHover is similar to hover.
    def must_hover : Element
      must_wrap hover
      self
    end

    # MustClick is similar to click.
    def must_click : Element
      must_wrap click(::Cdp::Input::MouseButton::Left, 1)
      self
    end

    # MustDoubleClick is similar to click.
    def must_double_click : Element
      must_wrap click(::Cdp::Input::MouseButton::Left, 2)
      self
    end

    # MustTap is similar to tap.
    def must_tap : Element
      must_wrap tap
      self
    end

    # MustInteractable is similar to interactable.
    def must_interactable : Bool
      must_wrap interactable
      true
    rescue ex : NotInteractableError
      false
    rescue ex
      e(ex)
      raise
    end

    # MustWaitInteractable is similar to wait_interactable.
    def must_wait_interactable : Element
      must_wrap wait_interactable
      self
    end

    # MustType is similar to type.
    def must_type(keys : Array(Input::Key)) : Element
      must_wrap type(keys)
      self
    end

    # MustKeyActions is similar to key_actions.
    def must_key_actions : KeyActions
      must_wrap key_actions
    end

    # MustSelectText is similar to select_text.
    def must_select_text(regex : String) : Element
      must_wrap select_text(regex)
      self
    end

    # MustSelectAllText is similar to select_all_text.
    def must_select_all_text : Element
      must_wrap select_all_text
      self
    end

    # MustInput is similar to input.
    def must_input(text : String) : Element
      must_wrap input(text)
      self
    end

    # MustInputTime is similar to input.
    def must_input_time(t : Time) : Element
      must_wrap input_time(t)
      self
    end

    # MustInputColor is similar to input_color.
    def must_input_color(color : String) : Element
      must_wrap input_color(color)
      self
    end

    # MustBlur is similar to blur.
    def must_blur : Element
      must_wrap blur
      self
    end

    # MustSelect is similar to select.
    # TODO: Implement select method
    # def must_select(selectors : Array(String)) : Element
    #   must_wrap select(selectors, true, SelectorType::Text)
    #   self
    # end

    # MustMatches is similar to matches.
    def must_matches(selector : String) : Bool
      must_wrap matches(selector)
    end

    # MustAttribute is similar to attribute.
    def must_attribute(name : String) : String?
      must_wrap attribute(name)
    end

    # MustProperty is similar to property.
    def must_property(name : String) : ::JSON::Any
      must_wrap property(name)
    end

    # MustDisabled is similar to disabled.
    def must_disabled : Bool
      must_wrap disabled
    end

    # MustContainsElement is similar to contains_element.
    def must_contains_element(target : Element) : Bool
      must_wrap contains_element(target)
    end

    # MustSetFiles is similar to set_files.
    def must_set_files(paths : Array(String)) : Element
      must_wrap set_files(paths)
      self
    end

    # MustText is similar to text.
    def must_text : String
      must_wrap text
    end

    # MustHTML is similar to html.
    def must_html : String
      must_wrap html
    end

    # MustVisible is similar to visible.
    def must_visible : Bool
      must_wrap visible
    end

    # MustWaitLoad is similar to wait_load.
    def must_wait_load : Element
      must_wrap wait_load
      self
    end

    # MustWaitStable is similar to wait_stable.
    def must_wait_stable : Element
      must_wrap wait_stable(300.milliseconds)
      self
    end

    # MustWait is similar to wait.
    def must_wait(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Element
      must_wrap wait(EvalOptions.new(js, params))
      self
    end

    # MustWaitVisible is similar to wait_visible.
    def must_wait_visible : Element
      must_wrap wait_visible
      self
    end

    # MustWaitInvisible is similar to wait_invisible.
    def must_wait_invisible : Element
      must_wrap wait_invisible
      self
    end

    # MustWaitEnabled is similar to wait_enabled.
    def must_wait_enabled : Element
      must_wrap wait_enabled
      self
    end

    # MustWaitWritable is similar to wait_writable.
    def must_wait_writable : Element
      must_wrap wait_writable
      self
    end

    # MustShape is similar to shape.
    def must_shape : ::Cdp::DOM::GetContentQuadsResult
      must_wrap shape
    end

    # MustCanvasToImage is similar to canvas_to_image.
    def must_canvas_to_image : Array(UInt8)
      must_wrap canvas_to_image("", -1)
    end

    # MustResource is similar to resource.
    def must_resource : Array(UInt8)
      must_wrap resource
    end

    # MustBackgroundImage is similar to background_image.
    def must_background_image : Array(UInt8)
      must_wrap background_image
    end

    # MustScreenshot is similar to screenshot.
    def must_screenshot(to_file : String? = nil) : Array(UInt8)
      bin = must_wrap screenshot(::Cdp::Page::CaptureScreenshotFormat::Png, 0)
      must_wrap save_file(SaveFileType::Screenshot, bin, to_file)
      bin
    end

    # MustRelease is similar to release.
    def must_release : Nil
      must_wrap release
    end

    # MustRemove is similar to remove.
    def must_remove : Nil
      must_wrap remove
    end

    # MustEval is similar to eval.
    def must_eval(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : ::JSON::Any
      res = must_wrap eval(js, params)
      res.value
    end

    # MustHas is similar to has.
    def must_has(selector : String) : Bool
      has, _ = must_wrap has(selector)
      has
    end

    # MustHasX is similar to has_x.
    def must_has_x(selector : String) : Bool
      has, _ = must_wrap has_x(selector)
      has
    end

    # MustHasR is similar to has_r.
    def must_has_r(selector : String, regex : String) : Bool
      has, _ = must_wrap has_r(selector, regex)
      has
    end

    # MustElement is similar to element.
    def must_element(selector : String) : Element
      must_wrap element(selector)
    end

    # MustElementX is similar to element_x.
    def must_element_x(xpath : String) : Element
      must_wrap element_x(xpath)
    end

    # MustElementByJS is similar to element_by_js.
    def must_element_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Element
      must_wrap element_by_js(EvalOptions.new(js, params))
    end

    # MustParent is similar to parent.
    def must_parent : Element
      must_wrap parent
    end

    # MustParents is similar to parents.
    def must_parents(selector : String) : Elements
      must_wrap parents(selector)
    end

    # MustNext is similar to next.
    def must_next : Element
      must_wrap self.next
    end

    # MustPrevious is similar to previous.
    def must_previous : Element
      must_wrap previous
    end

    # MustElementR is similar to element_r.
    def must_element_r(selector : String, regex : String) : Element
      must_wrap element_r(selector, regex)
    end

    # MustElements is similar to elements.
    def must_elements(selector : String) : Elements
      must_wrap elements(selector)
    end

    # MustElementsX is similar to elements_x.
    def must_elements_x(xpath : String) : Elements
      must_wrap elements_x(xpath)
    end

    # MustElementsByJS is similar to elements_by_js.
    def must_elements_by_js(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : Elements
      must_wrap elements_by_js(EvalOptions.new(js, params))
    end

    # MustEqual is similar to equal.
    def must_equal(elm : Element) : Bool
      must_wrap equal(elm)
    end

    # MustMoveMouseOut is similar to move_mouse_out.
    def must_move_mouse_out : Element
      must_wrap move_mouse_out
      self
    end

    # MustGetXPath is similar to get_xpath.
    def must_get_xpath(optimized : Bool = false) : String
      must_wrap get_xpath(optimized)
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
