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

  # Get modifier for a key
  def self.modifier(key : Key) : Int32
    # TODO: Implement proper modifier detection
    0
  end

  # Get key info
  def self.key_info(key : Key) : KeyInfo
    # TODO: Implement proper key info
    KeyInfo.new("", "", 0, 0)
  end

  # Encode key event for CDP
  def self.encode(key : Key, event_type : String, modifiers : Int32) : Cdp::Input::DispatchKeyEvent
    # TODO: Implement proper encoding
    Cdp::Input::DispatchKeyEvent.new(
      type: Cdp::Input::KeyType::KeyDown,
      modifiers: modifiers,
      timestamp: nil,
      text: nil,
      unmodified_text: nil,
      key_identifier: nil,
      code: nil,
      key: nil,
      windows_virtual_key_code: nil,
      native_virtual_key_code: nil,
      auto_repeat: nil,
      is_keypad: nil,
      is_system_key: nil,
      location: nil,
      commands: nil
    )
  end
end
