require "../../cdp/emulation/emulation"

module Rod::Lib::Devices
  # ScreenSize represents the size of a device screen.
  struct ScreenSize
    property width : Int32
    property height : Int32

    def initialize(@width : Int32, @height : Int32)
    end
  end

  # Screen represents the screen configuration for a device.
  struct Screen
    property device_pixel_ratio : Float64
    property horizontal : ScreenSize
    property vertical : ScreenSize

    def initialize(@device_pixel_ratio : Float64 = 0.0, @horizontal : ScreenSize = ScreenSize.new(0, 0), @vertical : ScreenSize = ScreenSize.new(0, 0))
    end
  end

  # Device represents an emulated device descriptor.
  struct Device
    property capabilities : Array(String)
    property user_agent : String
    property accept_language : String
    property screen : Screen
    property title : String

    def initialize(
      @capabilities : Array(String) = [] of String,
      @user_agent : String = "",
      @accept_language : String = "",
      @screen : Screen = Screen.new,
      @title : String = "",
      @landscape : Bool = false,
      @clear : Bool = false,
    )
    end

    # Landscape clones the device and marks it landscape.
    def landscape : Device
      Device.new(
        capabilities: @capabilities,
        user_agent: @user_agent,
        accept_language: @accept_language,
        screen: @screen,
        title: @title,
        landscape: true,
        clear: @clear
      )
    end

    # IsClear indicates if this descriptor clears emulation overrides.
    def clear? : Bool
      @clear
    end

    # MetricsEmulation returns the emulation metrics request.
    def metrics_emulation : ::Cdp::Emulation::SetDeviceMetricsOverride?
      return nil if clear?

      screen_size = @landscape ? @screen.horizontal : @screen.vertical
      orientation = if @landscape
                      ::Cdp::Emulation::ScreenOrientation.from_json(%({"type":"landscapePrimary","angle":90}))
                    else
                      ::Cdp::Emulation::ScreenOrientation.from_json(%({"type":"portraitPrimary","angle":0}))
                    end

      ::Cdp::Emulation::SetDeviceMetricsOverride.new(
        width: screen_size.width.to_i64,
        height: screen_size.height.to_i64,
        device_scale_factor: @screen.device_pixel_ratio,
        mobile: @capabilities.includes?("mobile"),
        scale: nil,
        screen_width: nil,
        screen_height: nil,
        position_x: nil,
        position_y: nil,
        dont_set_visible_size: nil,
        screen_orientation: orientation,
        viewport: nil,
        display_feature: nil,
        device_posture: nil
      )
    end

    # TouchEmulation returns the touch emulation request.
    def touch_emulation : ::Cdp::Emulation::SetTouchEmulationEnabled
      if clear?
        return ::Cdp::Emulation::SetTouchEmulationEnabled.new(
          enabled: false,
          max_touch_points: nil
        )
      end

      ::Cdp::Emulation::SetTouchEmulationEnabled.new(
        enabled: @capabilities.includes?("touch"),
        max_touch_points: 5_i64
      )
    end

    # UserAgentEmulation returns the user agent override request.
    def user_agent_emulation : ::Cdp::Emulation::SetUserAgentOverride?
      return nil if clear?

      ::Cdp::Emulation::SetUserAgentOverride.new(
        user_agent: @user_agent,
        accept_language: @accept_language,
        platform: nil,
        user_agent_metadata: nil
      )
    end
  end

  # Clear is used to clear emulation overrides.
  Clear = Device.new(clear: true)

  IPhone4 = Device.new(
    title: "iPhone 4",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D257 Safari/9537.53",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 480, height: 320),
      vertical: ScreenSize.new(width: 320, height: 480)
    )
  )

  IPhone5orSE = Device.new(
    title: "iPhone 5/SE",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 568, height: 320),
      vertical: ScreenSize.new(width: 320, height: 568)
    )
  )

  IPhone6or7or8 = Device.new(
    title: "iPhone 6/7/8",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 667, height: 375),
      vertical: ScreenSize.new(width: 375, height: 667)
    )
  )

  IPhone6or7or8Plus = Device.new(
    title: "iPhone 6/7/8 Plus",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 736, height: 414),
      vertical: ScreenSize.new(width: 414, height: 736)
    )
  )

  IPhoneX = Device.new(
    title: "iPhone X",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 812, height: 375),
      vertical: ScreenSize.new(width: 375, height: 812)
    )
  )

  BlackBerryZ30 = Device.new(
    title: "BlackBerry Z30",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (BB10; Touch) AppleWebKit/537.10+ (KHTML, like Gecko) Version/10.0.9.2372 Mobile Safari/537.10+",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  Nexus4 = Device.new(
    title: "Nexus 4",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 384),
      vertical: ScreenSize.new(width: 384, height: 640)
    )
  )

  Nexus5 = Device.new(
    title: "Nexus 5",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  Nexus5X = Device.new(
    title: "Nexus 5X",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 8.0.0; Nexus 5X Build/OPR4.170623.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 732, height: 412),
      vertical: ScreenSize.new(width: 412, height: 732)
    )
  )

  Nexus6 = Device.new(
    title: "Nexus 6",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 7.1.1; Nexus 6 Build/N6F26U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 732, height: 412),
      vertical: ScreenSize.new(width: 412, height: 732)
    )
  )

  Nexus6P = Device.new(
    title: "Nexus 6P",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 8.0.0; Nexus 6P Build/OPP3.170518.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 732, height: 412),
      vertical: ScreenSize.new(width: 412, height: 732)
    )
  )

  Pixel2 = Device.new(
    title: "Pixel 2",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 731, height: 411),
      vertical: ScreenSize.new(width: 411, height: 731)
    )
  )

  Pixel2XL = Device.new(
    title: "Pixel 2 XL",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 8.0.0; Pixel 2 XL Build/OPD1.170816.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 823, height: 411),
      vertical: ScreenSize.new(width: 411, height: 823)
    )
  )

  LGOptimusL70 = Device.new(
    title: "LG Optimus L70",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; LGMS323 Build/KOT49I.MS32310c) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 384),
      vertical: ScreenSize.new(width: 384, height: 640)
    )
  )

  NokiaN9 = Device.new(
    title: "Nokia N9",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 854, height: 480),
      vertical: ScreenSize.new(width: 480, height: 854)
    )
  )

  NokiaLumia520 = Device.new(
    title: "Nokia Lumia 520",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 520)",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 533, height: 320),
      vertical: ScreenSize.new(width: 320, height: 533)
    )
  )

  MicrosoftLumia550 = Device.new(
    title: "Microsoft Lumia 550",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 550) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 640, height: 360)
    )
  )

  MicrosoftLumia950 = Device.new(
    title: "Microsoft Lumia 950",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 4.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  GalaxySIII = Device.new(
    title: "Galaxy S III",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; U; Android 4.0; en-us; GT-I9300 Build/IMM76D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  GalaxyS5 = Device.new(
    title: "Galaxy S5",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  JioPhone2 = Device.new(
    title: "JioPhone 2",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Mobile; LYF/F300B/LYF-F300B-001-01-15-130718-i;Android; rv:48.0) Gecko/48.0 Firefox/48.0 KAIOS/2.5",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 320, height: 240),
      vertical: ScreenSize.new(width: 240, height: 320)
    )
  )

  KindleFireHDX = Device.new(
    title: "Kindle Fire HDX",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; U; en-us; KFAPWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.13 Safari/535.19 Silk-Accelerated=true",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 1280, height: 800),
      vertical: ScreenSize.new(width: 800, height: 1280)
    )
  )

  IPadMini = Device.new(
    title: "iPad Mini",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 1024, height: 768),
      vertical: ScreenSize.new(width: 768, height: 1024)
    )
  )

  IPad = Device.new(
    title: "iPad",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 1024, height: 768),
      vertical: ScreenSize.new(width: 768, height: 1024)
    )
  )

  IPadPro = Device.new(
    title: "iPad Pro",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 1366, height: 1024),
      vertical: ScreenSize.new(width: 1024, height: 1366)
    )
  )

  BlackberryPlayBook = Device.new(
    title: "Blackberry PlayBook",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (PlayBook; U; RIM Tablet OS 2.1.0; en-US) AppleWebKit/536.2+ (KHTML like Gecko) Version/7.2.1.0 Safari/536.2+",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 1024, height: 600),
      vertical: ScreenSize.new(width: 600, height: 1024)
    )
  )

  Nexus10 = Device.new(
    title: "Nexus 10",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 10 Build/MOB31T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 1280, height: 800),
      vertical: ScreenSize.new(width: 800, height: 1280)
    )
  )

  Nexus7 = Device.new(
    title: "Nexus 7",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 960, height: 600),
      vertical: ScreenSize.new(width: 600, height: 960)
    )
  )

  GalaxyNote3 = Device.new(
    title: "Galaxy Note 3",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; U; Android 4.3; en-us; SM-N900T Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  GalaxyNoteII = Device.new(
    title: "Galaxy Note II",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  LaptopWithTouch = Device.new(
    title: "Laptop with touch",
    capabilities: ["touch"],
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 1280, height: 950),
      vertical: ScreenSize.new(width: 950, height: 1280)
    )
  )

  LaptopWithHiDPIScreen = Device.new(
    title: "Laptop with HiDPI screen",
    capabilities: [] of String,
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 1440, height: 900),
      vertical: ScreenSize.new(width: 900, height: 1440)
    )
  )

  LaptopWithMDPIScreen = Device.new(
    title: "Laptop with MDPI screen",
    capabilities: [] of String,
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 1.to_f64,
      horizontal: ScreenSize.new(width: 1280, height: 800),
      vertical: ScreenSize.new(width: 800, height: 1280)
    )
  )

  MotoG4 = Device.new(
    title: "Moto G4",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 6.0.1; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 640, height: 360),
      vertical: ScreenSize.new(width: 360, height: 640)
    )
  )

  SurfaceDuo = Device.new(
    title: "Surface Duo",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 2.to_f64,
      horizontal: ScreenSize.new(width: 720, height: 540),
      vertical: ScreenSize.new(width: 540, height: 720)
    )
  )

  GalaxyFold = Device.new(
    title: "Galaxy Fold",
    capabilities: ["touch", "mobile"],
    user_agent: "Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    accept_language: "en",
    screen: Screen.new(
      device_pixel_ratio: 3.to_f64,
      horizontal: ScreenSize.new(width: 653, height: 280),
      vertical: ScreenSize.new(width: 280, height: 653)
    )
  )
end
