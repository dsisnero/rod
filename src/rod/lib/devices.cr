module Rod::Lib::Devices
  # Device descriptor
  struct Device
    property user_agent : String
    property viewport : Viewport

    def initialize(@user_agent, @viewport)
    end
  end

  struct Viewport
    property width : Int32
    property height : Int32
    property device_scale_factor : Float64
    property is_mobile : Bool
    property has_touch : Bool
    property is_landscape : Bool

    def initialize(@width, @height, @device_scale_factor = 1.0, @is_mobile = false, @has_touch = false, @is_landscape = false)
    end
  end

  # Predefined devices
  IPHONE_6 = Device.new(
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
    Viewport.new(375, 667, 2.0, true, true)
  )
end
