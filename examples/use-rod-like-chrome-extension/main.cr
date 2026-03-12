require "../../src/rod"
require "base64"
require "http/client"

ws_url = Rod::Lib::Launcher.new_user_mode.launch
browser = Rod::Browser.new.control_url(ws_url).must_connect.no_default_device

previewer = Rod::Browser.new.must_connect
cookies = browser.must_get_cookies
previewer.must_set_cookies(cookies)
pool = Rod.new_page_pool(5)
create = -> { previewer.must_page }

js_lib = HTTP::Client.get("https://unpkg.com/@popperjs/core@2").body + HTTP::Client.get("https://unpkg.com/tippy.js@6").body
js = <<-JS
window.addEventListener('load', () => {
  #{js_lib}
  function setup(el) {
    el.classList.add('x-set')
    tippy(el, {onShow: async (it) => {
      if (it.props.content.src) return
      let img = document.createElement('img')
      img.style.width = '400px'
      img.src = "data:image/png;base64," + await getPreview(el.href)
      it.setContent(img)
    }, content: 'loading...', maxWidth: 500})
  }
  (function check() {
    Array.from(document.querySelectorAll('a:not(.x-set)')).forEach(setup)
    setTimeout(check, 1000)
  })()
})
JS

callbacks = {} of String => Rod::Browser::CallbackInfo
callbacks[Cdp::Target::TargetCreatedEvent.proto_event] = Rod::Browser::CallbackInfo.new(
  Cdp::Target::TargetCreatedEvent,
  ->(event : Cdp::Event, _sid : Rod::SessionID?) do
    created = event.as(Cdp::Target::TargetCreatedEvent)
    next false unless created.target_info.type == Cdp::Target::TargetInfoTypePage

    page = browser.must_page_from_target_id(Rod::TargetID.new(created.target_info.target_id))
    page.must_eval_on_new_document(js)
    page.expose("getPreview", ->(url : JSON::Any) do
      p = pool.get(create)
      begin
        p.must_navigate(url.as_s)
        {JSON::Any.new(Base64.strict_encode(p.must_screenshot)), nil}
      ensure
        pool.put(p)
      end
    end)
    false
  end
)
spawn { browser.each_event(nil, callbacks).call }

browser.must_page
puts "Press Enter to exit..."
STDIN.gets
