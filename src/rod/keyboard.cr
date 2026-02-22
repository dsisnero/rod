require "mutex"
require "set"
require "./lib/input/input"

module Rod
  # Keyboard represents the keyboard on a page, it's always related the main frame.
  class Keyboard
    @mutex : Mutex
    @page : Page
    @pressed : Set(Input::Key)

    def initialize(@page : Page)
      @mutex = Mutex.new
      @pressed = Set(Input::Key).new
    end

    # Press the key down.
    # To input characters that are not on the keyboard, such as Chinese or Japanese, you should
    # use method like Page.InsertText.
    def press(key : Input::Key) : Nil
      @mutex.synchronize do
        @pressed.add(key)
        event = Input.encode(key, "keyDown", modifiers)
        event.call(@page)
      end
    end

    # Release the key.
    def release(key : Input::Key) : Nil
      @mutex.synchronize do
        unless @pressed.includes?(key)
          return
        end
        @pressed.delete(key)
        event = Input.encode(key, "keyUp", modifiers)
        event.call(@page)
      end
    end

    # Type releases the key after the press.
    def type(*keys : Input::Key) : Nil
      keys.each do |key|
        press(key)
        release(key)
      end
    end

    # KeyActionType enum.
    enum KeyActionType
      Press
      Release
      TypeKey
    end

    # KeyAction to perform.
    struct KeyAction
      property type : KeyActionType
      property key : Input::Key

      def initialize(@type, @key)
      end
    end

    # KeyActions to simulate.
    class KeyActions
      @keyboard : Keyboard
      @actions : Array(KeyAction)

      def initialize(@keyboard)
        @actions = [] of KeyAction
      end

      # Press keys is guaranteed to have a release at the end of actions.
      def press(*keys : Input::Key) : KeyActions
        keys.each do |key|
          @actions << KeyAction.new(KeyActionType::Press, key)
        end
        self
      end

      # Release keys.
      def release(*keys : Input::Key) : KeyActions
        keys.each do |key|
          @actions << KeyAction.new(KeyActionType::Release, key)
        end
        self
      end

      # Type will release the key immediately after the pressing.
      def type(*keys : Input::Key) : KeyActions
        keys.each do |key|
          @actions << KeyAction.new(KeyActionType::TypeKey, key)
        end
        self
      end

      # Do the actions.
      def do : Nil
        balanced_actions.each do |action|
          case action.type
          when KeyActionType::Press
            @keyboard.press(action.key)
          when KeyActionType::Release
            @keyboard.release(action.key)
          when KeyActionType::TypeKey
            @keyboard.type(action.key)
          end
        end
      end

      # Make sure there's at least one release after the presses, such as:
      #
      #	p1,p2,p1,r1 => p1,p2,p1,r1,r2
      private def balanced_actions : Array(KeyAction)
        actions = @actions
        h = Hash(Input::Key, Bool).new

        actions.each do |a|
          case a.type
          when KeyActionType::Press
            h[a.key] = true
          when KeyActionType::Release, KeyActionType::TypeKey
            h[a.key] = false
          end
        end

        h.each do |key, need_release|
          if need_release
            actions << KeyAction.new(KeyActionType::Release, key)
          end
        end

        actions
      end
    end

    # KeyActions simulates the type actions on a physical keyboard.
    # Useful when input shortcuts like ctrl+enter .
    def key_actions : KeyActions
      KeyActions.new(self)
    end

    private def key_info(key : Input::Key) : Input::KeyInfo
      Input.key_info(key)
    end

    # Get current modifier flags.
    def modifiers : Int32
      @mutex.synchronize do
        ms = 0
        @pressed.each do |key|
          ms |= Input.modifier(key)
        end
        ms
      end
    end
  end
end
