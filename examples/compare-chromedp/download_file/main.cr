require "../../../src/rod"

wd = Dir.current
browser = Rod::Browser.new.must_connect
page = browser.must_page("https://github.com/chromedp/examples")

code_toggle = page.must_element_by_js <<-JS
() => {
  const norm = s => (s || "").replace(/\\s+/g, " ").trim().toLowerCase();
  return Array.from(document.querySelectorAll("button,summary")).find(el => {
    const text = norm(el.textContent);
    const label = norm(el.getAttribute && el.getAttribute("aria-label"));
    return text === "code" || label === "code" || text.startsWith("code ");
  }) || null;
}
JS
code_toggle.must_click

wait = page.browser.wait_download(wd)

callbacks = {} of String => Rod::Browser::CallbackInfo
callbacks[Cdp::Browser::DownloadProgressEvent.proto_event] = Rod::Browser::CallbackInfo.new(
  Cdp::Browser::DownloadProgressEvent,
  ->(event : Cdp::Event, _sid : Rod::SessionID?) do
    progress = event.as(Cdp::Browser::DownloadProgressEvent)
    completed = if progress.total_bytes.zero?
                  "(unknown)"
                else
                  "#{(progress.received_bytes / progress.total_bytes * 100.0).round(2)}%"
                end
    Log.info { "state: #{progress.state}, completed: #{completed}" }
    progress.state == Cdp::Browser::DownloadProgressStateCompleted
  end
)
spawn { browser.each_event(nil, callbacks).call }

download = page.must_element_by_js <<-JS
() => {
  const norm = s => (s || "").replace(/\\s+/g, " ").trim().toLowerCase();

  const byText = Array.from(document.querySelectorAll("a,button,[role='menuitem']")).find(el => {
    const text = norm(el.textContent);
    const label = norm(el.getAttribute && el.getAttribute("aria-label"));
    return text === "download zip" || label === "download zip";
  });
  if (byText) return byText.closest("a,button,[role='menuitem']");

  return Array.from(document.querySelectorAll("a[href]")).find(a =>
    /\\/archive\\/refs\\/heads\\/[^/]+\\.zip($|\\?)/.test(a.getAttribute("href") || "")
  ) || null;
}
JS
download.must_click

res = wait.call
Log.info { "wrote #{File.join(wd, res.not_nil!.guid)}" }
