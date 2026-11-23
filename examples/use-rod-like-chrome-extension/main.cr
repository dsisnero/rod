require "../../src/rod"
require "base64"
require "http/client"

# Ported from `vendor/rod/lib/examples/use-rod-like-chrome-extension/main.go`:
# reuse your logged-in browser profile, then attach a "link previewer" to every
# page it opens, like a browser extension would.
#
# Make sure the browser is fully closed first: user mode can only control a
# browser it launched itself.
ws_url = Rod::Util::Launcher.new_user_mode.launch
browser = Rod::Browser.new.control_url(ws_url).connect!.no_default_device

# A headless browser renders the previews in the background and shares the
# user-mode cookies.
previewer = Rod::Browser.new.connect!
previewer.set_cookies!(browser.get_cookies!)
pool = Rod.new_page_pool(5)

js_lib = HTTP::Client.get("https://unpkg.com/@popperjs/core@2").body +
         HTTP::Client.get("https://unpkg.com/tippy.js@6").body
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
    if created.target_info.type == "page"
      page = browser.page_from_target_id!(Rod::TargetID.new(created.target_info.target_id))
      # Inject the extension into every new page.
      page.eval_on_new_document!(js)

      # Expose the preview generator the injected script calls.
      page.expose!("getPreview", ->(url : JSON::Any) do
        preview_page = pool.get! { previewer.page! }
        begin
          preview_page.navigate!(url.as_s)
          {JSON::Any.new(Base64.strict_encode(preview_page.screenshot!)), nil}
        ensure
          pool.put(preview_page)
        end
      end)
    end
    false
  end
)
spawn { browser.each_event(nil, callbacks).call }

browser.page!
puts "Press Enter to exit..."
STDIN.gets
