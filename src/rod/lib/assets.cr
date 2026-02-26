module Rod::Lib::Assets
  MousePointer = <<-'SVG'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="277px" height="401px" viewBox="0 0 277 401" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <title>mouse-pointer</title>
  <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
    <polygon fill="#FFFFFF" points="0 0 0 299 60 241 103 341 170 313 130 218 217 216"></polygon>
    <polygon fill="#000000" points="18 44 18 255 66 207 110 313 145 299 102 198 171 197"></polygon>
  </g>
</svg>
SVG

  Monitor = <<-'HTML'
<html>
  <head>
    <title>Rod Monitor - Pages</title>
    <style>
      body { margin: 0; background: #2d2c2f; color: white; padding: 20px; font-family: sans-serif; }
      a { color: white; padding: 1em; margin: 0.5em 0; font-size: 1em; text-decoration: none; display: block; border-radius: 0.3em; border: 1px solid transparent; background: #212225; }
      a:visited { color: #c3c3c3; }
      a:hover { background: #25272d; border-color: #8d8d96; }
    </style>
  </head>
  <body>
    <h3>Choose a Page to Monitor</h3>
    <div id="targets"></div>
    <script>
      async function update() {
        const list = await (await fetch('/api/pages')).json()
        let html = ''
        list.forEach((el) => {
          html += `<a href='/page/${el.targetId}' title="${el.url}">${el.title}</a>`
        })
        window.targets.innerHTML = html
        setTimeout(update, 1000)
      }
      update()
    </script>
  </body>
</html>
HTML

  MonitorPage = <<-'HTML'
<html>
  <head>
    <style>
      body { margin: 0; background: #2d2c2f; color: #ffffff; }
      .navbar { font-family: sans-serif; border-bottom: 1px solid #1413158c; display: flex; flex-direction: row; }
      .error { color: #ff3f3f; background: #3e1f1f; border-bottom: 1px solid #1413158c; display: none; padding: 10px; margin: 0; }
      input { background: transparent; color: white; border: 1px solid #4f475a; border-radius: 3px; padding: 5px; margin: 5px; }
      .title { flex: 2; }
      .url { flex: 5; }
      .rate { flex: 1; }
    </style>
  </head>
  <body>
    <div class="navbar">
      <input type="text" class="title" readonly />
      <input type="text" class="url" readonly />
      <input type="number" class="rate" value="0.5" min="0" step="0.1" />
    </div>
    <pre class="error"></pre>
    <img class="screen" />
  </body>
  <script>
    const id = location.pathname.split('/').slice(-1)[0]
    const elImg = document.querySelector('.screen')
    const elTitle = document.querySelector('.title')
    const elUrl = document.querySelector('.url')
    const elRate = document.querySelector('.rate')
    const elErr = document.querySelector('.error')

    document.title = `Rod Monitor - ${id}`

    async function update() {
      const res = await fetch(`/api/page/${id}`)
      const info = await res.json()
      elTitle.value = info.title || ''
      elUrl.value = info.url || ''

      await new Promise((resolve, reject) => {
        const now = new Date()
        elImg.src = `/screenshot/${id}?t=${now.getTime()}`
        elImg.style.maxWidth = innerWidth + 'px'
        elImg.onload = resolve
        elImg.onerror = () => reject(new Error('error loading screenshots'))
      })
    }

    async function mainLoop() {
      try {
        await update()
        elErr.style.display = 'none'
      } catch (err) {
        elErr.style.display = 'block'
        elErr.textContent = err + ''
      }
      setTimeout(mainLoop, parseFloat(elRate.value) * 1000)
    }

    mainLoop()
  </script>
</html>
HTML
end
