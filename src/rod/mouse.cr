require "mutex"
require "./types"
require "./lib/input/input"

module Rod
  # Mouse represents the mouse on a page, it's always related the main frame.
  class Mouse
    @mutex : Mutex
    @page : Page
    @id : String # mouse svg dom element id
    @pos : Point
    @buttons : Array(String) # the buttons is currently being pressed, reflects the press order

    def initialize(@page : Page)
      @mutex = Mutex.new
      @id = Random::Secure.hex(4) # 8 characters
      @pos = Point.new(0, 0)
      @buttons = [] of String
    end

    # Position of current cursor.
    def position : Point
      @mutex.synchronize do
        @pos
      end
    end

    # MoveTo the absolute position.
    def move_to(p : Point) : Nil
      @mutex.synchronize do
        button, buttons = Input.encode_mouse_button(@buttons)
        @page.browser.try_slow_motion

        event = Cdp::Input::DispatchMouseEvent.new(
          type: "mouseMoved",
          x: p.x,
          y: p.y,
          modifiers: @page.keyboard.modifiers,
          timestamp: nil,
          button: button,
          buttons: buttons,
          click_count: nil,
          force: nil,
          tangential_pressure: nil,
          tilt_x: nil,
          tilt_y: nil,
          twist: nil,
          delta_x: nil,
          delta_y: nil,
          pointer_type: nil
        )
        event.call(@page)

        # to make sure set only when call is successful
        @pos = p

        if @page.browser.trace?
          unless update_mouse_tracer
            init_mouse_tracer
            update_mouse_tracer
          end
        end
      end
    end

    # MoveAlong the guide function.
    # Every time the guide function is called it should return the next mouse position, return true to stop.
    # Read the source code of Mouse.MoveLinear as an example to use this method.
    def move_along(&guide : -> {Point, Bool}) : Nil
      loop do
        p, stop = guide.call
        if stop
          move_to(p)
          return
        end
        move_to(p)
      end
    end

    # MoveLinear to the absolute position with the given steps.
    # Such as move from (0,0) to (6,6) with 3 steps, the mouse will first move to (2,2) then (4,4) then (6,6).
    def move_linear(to : Point, steps : Int32) : Nil
      p = position
      step = to.minus(p).scale(1 / steps.to_f)
      count = 0

      move_along do
        count += 1
        if count == steps
          {to, true}
        else
          p = p.add(step)
          {p, false}
        end
      end
    end

    # Scroll the relative offset with specified steps.
    def scroll(offset_x : Float64, offset_y : Float64, steps : Int32) : Nil
      @mutex.synchronize do
        @page.browser.try_slow_motion

        if steps < 1
          steps = 1
        end

        button, buttons = Input.encode_mouse_button(@buttons)

        step_x = offset_x / steps.to_f
        step_y = offset_y / steps.to_f

        steps.times do |_i|
          event = Cdp::Input::DispatchMouseEvent.new(
            type: "mouseWheel",
            x: @pos.x,
            y: @pos.y,
            modifiers: @page.keyboard.modifiers,
            timestamp: nil,
            button: button,
            buttons: buttons,
            click_count: nil,
            force: nil,
            tangential_pressure: nil,
            tilt_x: nil,
            tilt_y: nil,
            twist: nil,
            delta_x: step_x,
            delta_y: step_y,
            pointer_type: nil
          )
          event.call(@page)
        end
      end
    end

    # Down holds the button down.
    def down(button : String, click_count : Int32 = 1) : Nil
      @mutex.synchronize do
        to_buttons = @buttons + [button]
        _, buttons = Input.encode_mouse_button(to_buttons)

        event = Cdp::Input::DispatchMouseEvent.new(
          type: "mousePressed",
          x: @pos.x,
          y: @pos.y,
          modifiers: @page.keyboard.modifiers,
          timestamp: nil,
          button: button,
          buttons: buttons,
          click_count: click_count,
          force: nil,
          tangential_pressure: nil,
          tilt_x: nil,
          tilt_y: nil,
          twist: nil,
          delta_x: nil,
          delta_y: nil,
          pointer_type: nil
        )
        event.call(@page)
        @buttons = to_buttons
      end
    end

    # Up releases the button.
    def up(button : String, click_count : Int32 = 1) : Nil
      @mutex.synchronize do
        to_buttons = @buttons.reject { |btn| btn == button }
        _, buttons = Input.encode_mouse_button(to_buttons)

        event = Cdp::Input::DispatchMouseEvent.new(
          type: "mouseReleased",
          x: @pos.x,
          y: @pos.y,
          modifiers: @page.keyboard.modifiers,
          timestamp: nil,
          button: button,
          buttons: buttons,
          click_count: click_count,
          force: nil,
          tangential_pressure: nil,
          tilt_x: nil,
          tilt_y: nil,
          twist: nil,
          delta_x: nil,
          delta_y: nil,
          pointer_type: nil
        )
        event.call(@page)
        @buttons = to_buttons
      end
    end

    # Click the button. It's the combination of Mouse.Down and Mouse.Up.
    def click(button : String, click_count : Int32 = 1) : Nil
      @page.browser.try_slow_motion
      down(button, click_count)
      up(button, click_count)
    end
  end
end
