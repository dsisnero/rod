module Rod::Input
  # Key represents a keyboard key
  alias Key = Int32

  # KeyInfo holds information about a key
  struct KeyInfo
    property key : String
    property code : String
    property key_code : Int32
    property location : Int32

    def initialize(@key, @code, @key_code, @location)
    end
  end

  # Modifier values
  MODIFIER_ALT     = 1
  MODIFIER_CONTROL = 2
  MODIFIER_META    = 4
  MODIFIER_SHIFT   = 8

  # Key maps (matching Go implementation)
  @@key_map = {} of Key => KeyInfo
  @@key_map_shifted = {} of Key => KeyInfo
  @@key_shifted_map = {} of Key => Key
  @@is_mac = false

  # Mac toggles whether mac editing commands are emitted.
  def self.mac? : Bool
    @@is_mac
  end

  def self.mac=(value : Bool) : Bool
    @@is_mac = value
  end

  MAC_COMMANDS = {
    "ArrowDown" => ["moveDown"],
  } of String => Array(String)

  # Add key to key map
  # Returns the Key identifier
  def self.add_key(key : String, shifted_key : String, code : String, key_code : Int32, location : Int32) : Key
    if key.size == 1
      r = key[0].ord.to_i32
      if !@@key_map.has_key?(r)
        @@key_map[r] = KeyInfo.new(key, code, key_code, location)

        if shifted_key.size == 1
          rs = shifted_key[0].ord.to_i32
          @@key_map_shifted[rs] = KeyInfo.new(shifted_key, code, key_code, location)
          @@key_shifted_map[r] = rs
        end
        return r
      end
    end

    k = key_code + (location + 1) * 256
    @@key_map[k] = KeyInfo.new(key, code, key_code, location)
    k
  end

  # Get modifier for a key
  def self.modifier(key : Key) : Int32
    info = key_info(key)
    case info.key_code
    when 18
      MODIFIER_ALT
    when 17
      MODIFIER_CONTROL
    when 91, 92
      MODIFIER_META
    when 16
      MODIFIER_SHIFT
    else
      0
    end
  end

  # Get key info
  def self.key_info(key : Key) : KeyInfo
    if info = @@key_map[key]?
      return info
    end
    if info = @@key_map_shifted[key]?
      return info
    end
    raise "key not defined: #{key}"
  end

  # Check if key is printable (single character)
  def self.printable?(key : Key) : Bool
    key_info(key).key.size == 1
  end

  # Get shifted version of key if available
  def self.shifted(key : Key) : {Key, Bool}
    if shifted = @@key_shifted_map[key]?
      {shifted, true}
    else
      {key, false}
    end
  end

  # Encode key event for CDP
  def self.encode(key : Key, event_type : String, modifiers : Int32) : Cdp::Input::DispatchKeyEvent
    # Determine event type (keyDown vs rawKeyDown)
    type = event_type
    if event_type == "keyDown" && !printable?(key)
      type = "rawKeyDown"
    end

    info = key_info(key)
    location = info.location == 3 ? nil : info.location.to_i64?
    keypad = info.location == 3

    text = printable?(key) ? info.key : ""

    commands = mac? ? MAC_COMMANDS[info.key]? : nil
    modifier_bits = modifiers == 0 ? nil : Cdp::Input::Modifier.new(modifiers.to_i64)

    Cdp::Input::DispatchKeyEvent.new(
      type: type,
      modifiers: modifier_bits,
      timestamp: nil,
      text: text,
      unmodified_text: text,
      key_identifier: nil,
      code: info.code,
      key: info.key,
      windows_virtual_key_code: info.key_code.to_i64?,
      native_virtual_key_code: nil,
      auto_repeat: false,
      is_keypad: keypad,
      is_system_key: false,
      location: location,
      commands: commands
    )
  end

  # Key constants (matching Go keymap.go)
  # Functions row
  ESCAPE = add_key("Escape", "", "Escape", 27, 0)
  F1     = add_key("F1", "", "F1", 112, 0)
  F2     = add_key("F2", "", "F2", 113, 0)
  F3     = add_key("F3", "", "F3", 114, 0)
  F4     = add_key("F4", "", "F4", 115, 0)
  F5     = add_key("F5", "", "F5", 116, 0)
  F6     = add_key("F6", "", "F6", 117, 0)
  F7     = add_key("F7", "", "F7", 118, 0)
  F8     = add_key("F8", "", "F8", 119, 0)
  F9     = add_key("F9", "", "F9", 120, 0)
  F10    = add_key("F10", "", "F10", 121, 0)
  F11    = add_key("F11", "", "F11", 122, 0)
  F12    = add_key("F12", "", "F12", 123, 0)

  # Numbers row
  BACKQUOTE = add_key("`", "~", "Backquote", 192, 0)
  DIGIT1    = add_key("1", "!", "Digit1", 49, 0)
  DIGIT2    = add_key("2", "@", "Digit2", 50, 0)
  DIGIT3    = add_key("3", "#", "Digit3", 51, 0)
  DIGIT4    = add_key("4", "$", "Digit4", 52, 0)
  DIGIT5    = add_key("5", "%", "Digit5", 53, 0)
  DIGIT6    = add_key("6", "^", "Digit6", 54, 0)
  DIGIT7    = add_key("7", "&", "Digit7", 55, 0)
  DIGIT8    = add_key("8", "*", "Digit8", 56, 0)
  DIGIT9    = add_key("9", "(", "Digit9", 57, 0)
  DIGIT0    = add_key("0", ")", "Digit0", 48, 0)
  MINUS     = add_key("-", "_", "Minus", 189, 0)
  EQUAL     = add_key("=", "+", "Equal", 187, 0)
  BACKSLASH = add_key("\\", "|", "Backslash", 220, 0)
  BACKSPACE = add_key("Backspace", "", "Backspace", 8, 0)

  # First row
  TAB           = add_key("\t", "", "Tab", 9, 0)
  KEY_Q         = add_key("q", "Q", "KeyQ", 81, 0)
  KEY_W         = add_key("w", "W", "KeyW", 87, 0)
  KEY_E         = add_key("e", "E", "KeyE", 69, 0)
  KEY_R         = add_key("r", "R", "KeyR", 82, 0)
  KEY_T         = add_key("t", "T", "KeyT", 84, 0)
  KEY_Y         = add_key("y", "Y", "KeyY", 89, 0)
  KEY_U         = add_key("u", "U", "KeyU", 85, 0)
  KEY_I         = add_key("i", "I", "KeyI", 73, 0)
  KEY_O         = add_key("o", "O", "KeyO", 79, 0)
  KEY_P         = add_key("p", "P", "KeyP", 80, 0)
  BRACKET_LEFT  = add_key("[", "{", "BracketLeft", 219, 0)
  BRACKET_RIGHT = add_key("]", "}", "BracketRight", 221, 0)

  # Second row
  CAPSLOCK  = add_key("CapsLock", "", "CapsLock", 20, 0)
  KEY_A     = add_key("a", "A", "KeyA", 65, 0)
  KEY_S     = add_key("s", "S", "KeyS", 83, 0)
  KEY_D     = add_key("d", "D", "KeyD", 68, 0)
  KEY_F     = add_key("f", "F", "KeyF", 70, 0)
  KEY_G     = add_key("g", "G", "KeyG", 71, 0)
  KEY_H     = add_key("h", "H", "KeyH", 72, 0)
  KEY_J     = add_key("j", "J", "KeyJ", 74, 0)
  KEY_K     = add_key("k", "K", "KeyK", 75, 0)
  KEY_L     = add_key("l", "L", "KeyL", 76, 0)
  SEMICOLON = add_key(";", ":", "Semicolon", 186, 0)
  QUOTE     = add_key("'", "\"", "Quote", 222, 0)
  ENTER     = add_key("\r", "", "Enter", 13, 0)

  # Third row
  SHIFT_LEFT  = add_key("Shift", "", "ShiftLeft", 16, 1)
  KEY_Z       = add_key("z", "Z", "KeyZ", 90, 0)
  KEY_X       = add_key("x", "X", "KeyX", 88, 0)
  KEY_C       = add_key("c", "C", "KeyC", 67, 0)
  KEY_V       = add_key("v", "V", "KeyV", 86, 0)
  KEY_B       = add_key("b", "B", "KeyB", 66, 0)
  KEY_N       = add_key("n", "N", "KeyN", 78, 0)
  KEY_M       = add_key("m", "M", "KeyM", 77, 0)
  COMMA       = add_key(",", "<", "Comma", 188, 0)
  PERIOD      = add_key(".", ">", "Period", 190, 0)
  SLASH       = add_key("/", "?", "Slash", 191, 0)
  SHIFT_RIGHT = add_key("Shift", "", "ShiftRight", 16, 2)

  # Last row
  CONTROL_LEFT  = add_key("Control", "", "ControlLeft", 17, 1)
  META_LEFT     = add_key("Meta", "", "MetaLeft", 91, 1)
  ALT_LEFT      = add_key("Alt", "", "AltLeft", 18, 1)
  SPACE         = add_key(" ", "", "Space", 32, 0)
  ALT_RIGHT     = add_key("Alt", "", "AltRight", 18, 2)
  ALT_GRAPH     = add_key("AltGraph", "", "AltGraph", 225, 0)
  META_RIGHT    = add_key("Meta", "", "MetaRight", 92, 2)
  CONTEXT_MENU  = add_key("ContextMenu", "", "ContextMenu", 93, 0)
  CONTROL_RIGHT = add_key("Control", "", "ControlRight", 17, 2)

  # Center block
  PRINT_SCREEN = add_key("PrintScreen", "", "PrintScreen", 44, 0)
  SCROLL_LOCK  = add_key("ScrollLock", "", "ScrollLock", 145, 0)
  PAUSE        = add_key("Pause", "", "Pause", 19, 0)
  PAGE_UP      = add_key("PageUp", "", "PageUp", 33, 0)
  PAGE_DOWN    = add_key("PageDown", "", "PageDown", 34, 0)
  INSERT       = add_key("Insert", "", "Insert", 45, 0)
  DELETE       = add_key("Delete", "", "Delete", 46, 0)
  HOME         = add_key("Home", "", "Home", 36, 0)
  END          = add_key("End", "", "End", 35, 0)
  ARROW_LEFT   = add_key("ArrowLeft", "", "ArrowLeft", 37, 0)
  ARROW_UP     = add_key("ArrowUp", "", "ArrowUp", 38, 0)
  ARROW_RIGHT  = add_key("ArrowRight", "", "ArrowRight", 39, 0)
  ARROW_DOWN   = add_key("ArrowDown", "", "ArrowDown", 40, 0)

  # Numpad
  NUM_LOCK        = add_key("NumLock", "", "NumLock", 144, 0)
  NUMPAD_DIVIDE   = add_key("/", "", "NumpadDivide", 111, 3)
  NUMPAD_MULTIPLY = add_key("*", "", "NumpadMultiply", 106, 3)
  NUMPAD_SUBTRACT = add_key("-", "", "NumpadSubtract", 109, 3)
  NUMPAD7         = add_key("7", "", "Numpad7", 36, 3)
  NUMPAD8         = add_key("8", "", "Numpad8", 38, 3)
  NUMPAD9         = add_key("9", "", "Numpad9", 33, 3)
  NUMPAD4         = add_key("4", "", "Numpad4", 37, 3)
  NUMPAD5         = add_key("5", "", "Numpad5", 12, 3)
  NUMPAD6         = add_key("6", "", "Numpad6", 39, 3)
  NUMPAD_ADD      = add_key("+", "", "NumpadAdd", 107, 3)
  NUMPAD1         = add_key("1", "", "Numpad1", 35, 3)
  NUMPAD2         = add_key("2", "", "Numpad2", 40, 3)
  NUMPAD3         = add_key("3", "", "Numpad3", 34, 3)
  NUMPAD0         = add_key("0", "", "Numpad0", 45, 3)
  NUMPAD_DECIMAL  = add_key(".", "", "NumpadDecimal", 46, 3)
  NUMPAD_ENTER    = add_key("\r", "", "NumpadEnter", 13, 3)

  # Mouse button constants
  MOUSE_BUTTON_NONE    = "none"
  MOUSE_BUTTON_LEFT    = "left"
  MOUSE_BUTTON_MIDDLE  = "middle"
  MOUSE_BUTTON_RIGHT   = "right"
  MOUSE_BUTTON_BACK    = "back"
  MOUSE_BUTTON_FORWARD = "forward"

  # Mouse key bit flags (matching Go implementation)
  MOUSE_KEY_LEFT    =  1
  MOUSE_KEY_RIGHT   =  2
  MOUSE_KEY_MIDDLE  =  4
  MOUSE_KEY_BACK    =  8
  MOUSE_KEY_FORWARD = 16

  # Encode mouse button into button flag.
  # Returns a tuple of (primary_button, button_flags)
  def self.encode_mouse_button(buttons : Array(String)) : {String, Int32}
    flag = 0
    buttons.each do |btn|
      case btn
      when MOUSE_BUTTON_LEFT
        flag |= MOUSE_KEY_LEFT
      when MOUSE_BUTTON_RIGHT
        flag |= MOUSE_KEY_RIGHT
      when MOUSE_BUTTON_MIDDLE
        flag |= MOUSE_KEY_MIDDLE
      when MOUSE_BUTTON_BACK
        flag |= MOUSE_KEY_BACK
      when MOUSE_BUTTON_FORWARD
        flag |= MOUSE_KEY_FORWARD
      end
    end

    primary_button = buttons.empty? ? MOUSE_BUTTON_NONE : buttons.first
    {primary_button, flag}
  end
end
