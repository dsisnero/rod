require "./types"
require "./lib/input/input"

module Rod
  # Touch presents a touch device, such as a hand with fingers, each finger is a Cdp::Input::TouchPoint.
  # Touch events is stateless, we use the struct here only as a namespace to make the API style unified.
  class Touch
    @page : Page

    def initialize(@page : Page)
    end

    # Start a touch action.
    def start(*points : Cdp::Input::TouchPoint) : Nil
      # TODO: https://crbug.com/613219
      # WaitRepaint called twice
      # _ = t.page.WaitRepaint()
      # _ = t.page.WaitRepaint()

      event = Cdp::Input::DispatchTouchEvent.new(
        type: "touchStart",
        touch_points: points.to_a,
        modifiers: @page.keyboard.modifiers,
        timestamp: nil
      )
      event.call(@page)
    end

    # Move touch points. Use the Cdp::Input::TouchPoint.id (Touch.identifier) to track points.
    # Doc: https://developer.mozilla.org/en-US/docs/Web/API/Touch_events
    def move(*points : Cdp::Input::TouchPoint) : Nil
      event = Cdp::Input::DispatchTouchEvent.new(
        type: "touchMove",
        touch_points: points.to_a,
        modifiers: @page.keyboard.modifiers,
        timestamp: nil
      )
      event.call(@page)
    end

    # End touch action.
    def end : Nil
      event = Cdp::Input::DispatchTouchEvent.new(
        type: "touchEnd",
        touch_points: [] of Cdp::Input::TouchPoint,
        modifiers: @page.keyboard.modifiers,
        timestamp: nil
      )
      event.call(@page)
    end

    # Cancel touch action.
    def cancel : Nil
      event = Cdp::Input::DispatchTouchEvent.new(
        type: "touchCancel",
        touch_points: [] of Cdp::Input::TouchPoint,
        modifiers: @page.keyboard.modifiers,
        timestamp: nil
      )
      event.call(@page)
    end

    # Tap dispatches a touchstart and touchend event.
    def tap(x : Float64, y : Float64) : Nil
      # TODO: tryTrace, trySlowMotion
      point = Cdp::Input::TouchPoint.new(x: x, y: y)
      start(point)
      self.end
    end
  end
end
