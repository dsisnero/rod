require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Browser
  @[Experimental]
  alias BrowserContextID = String

  @[Experimental]
  alias WindowID = Int64

  @[Experimental]
  alias WindowState = String
  WindowStateNormal     = "normal"
  WindowStateMinimized  = "minimized"
  WindowStateMaximized  = "maximized"
  WindowStateFullscreen = "fullscreen"

  @[Experimental]
  struct Bounds
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property left : Int64?
    @[JSON::Field(emit_null: false)]
    property top : Int64?
    @[JSON::Field(emit_null: false)]
    property width : Int64?
    @[JSON::Field(emit_null: false)]
    property height : Int64?
    @[JSON::Field(emit_null: false)]
    property window_state : Cdp::NodeType?
  end

  @[Experimental]
  alias PermissionType = String
  PermissionTypeAr                       = "ar"
  PermissionTypeAudioCapture             = "audioCapture"
  PermissionTypeAutomaticFullscreen      = "automaticFullscreen"
  PermissionTypeBackgroundFetch          = "backgroundFetch"
  PermissionTypeBackgroundSync           = "backgroundSync"
  PermissionTypeCameraPanTiltZoom        = "cameraPanTiltZoom"
  PermissionTypeCapturedSurfaceControl   = "capturedSurfaceControl"
  PermissionTypeClipboardReadWrite       = "clipboardReadWrite"
  PermissionTypeClipboardSanitizedWrite  = "clipboardSanitizedWrite"
  PermissionTypeDisplayCapture           = "displayCapture"
  PermissionTypeDurableStorage           = "durableStorage"
  PermissionTypeGeolocation              = "geolocation"
  PermissionTypeHandTracking             = "handTracking"
  PermissionTypeIdleDetection            = "idleDetection"
  PermissionTypeKeyboardLock             = "keyboardLock"
  PermissionTypeLocalFonts               = "localFonts"
  PermissionTypeLocalNetwork             = "localNetwork"
  PermissionTypeLocalNetworkAccess       = "localNetworkAccess"
  PermissionTypeLoopbackNetwork          = "loopbackNetwork"
  PermissionTypeMidi                     = "midi"
  PermissionTypeMidiSysex                = "midiSysex"
  PermissionTypeNfc                      = "nfc"
  PermissionTypeNotifications            = "notifications"
  PermissionTypePaymentHandler           = "paymentHandler"
  PermissionTypePeriodicBackgroundSync   = "periodicBackgroundSync"
  PermissionTypePointerLock              = "pointerLock"
  PermissionTypeProtectedMediaIdentifier = "protectedMediaIdentifier"
  PermissionTypeSensors                  = "sensors"
  PermissionTypeSmartCard                = "smartCard"
  PermissionTypeSpeakerSelection         = "speakerSelection"
  PermissionTypeStorageAccess            = "storageAccess"
  PermissionTypeTopLevelStorageAccess    = "topLevelStorageAccess"
  PermissionTypeVideoCapture             = "videoCapture"
  PermissionTypeVr                       = "vr"
  PermissionTypeWakeLockScreen           = "wakeLockScreen"
  PermissionTypeWakeLockSystem           = "wakeLockSystem"
  PermissionTypeWebAppInstallation       = "webAppInstallation"
  PermissionTypeWebPrinting              = "webPrinting"
  PermissionTypeWindowManagement         = "windowManagement"

  @[Experimental]
  alias PermissionSetting = String
  PermissionSettingGranted = "granted"
  PermissionSettingDenied  = "denied"
  PermissionSettingPrompt  = "prompt"

  @[Experimental]
  struct PermissionDescriptor
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property? sysex : Bool?
    @[JSON::Field(emit_null: false)]
    property? user_visible_only : Bool?
    @[JSON::Field(emit_null: false)]
    property? allow_without_sanitization : Bool?
    @[JSON::Field(emit_null: false)]
    property? allow_without_gesture : Bool?
    @[JSON::Field(emit_null: false)]
    property? pan_tilt_zoom : Bool?
  end

  @[Experimental]
  alias BrowserCommandId = String
  BrowserCommandIdOpenTabSearch  = "openTabSearch"
  BrowserCommandIdCloseTabSearch = "closeTabSearch"
  BrowserCommandIdOpenGlic       = "openGlic"

  @[Experimental]
  struct Bucket
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property low : Int64
    @[JSON::Field(emit_null: false)]
    property high : Int64
    @[JSON::Field(emit_null: false)]
    property count : Int64
  end

  @[Experimental]
  struct Histogram
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property sum : Int64
    @[JSON::Field(emit_null: false)]
    property count : Int64
    @[JSON::Field(emit_null: false)]
    property buckets : Array(Cdp::NodeType)
  end

  @[Experimental]
  alias PrivacySandboxAPI = String
  PrivacySandboxAPIBiddingAndAuctionServices = "BiddingAndAuctionServices"
  PrivacySandboxAPITrustedKeyValue           = "TrustedKeyValue"

  alias DownloadProgressState = String
  DownloadProgressStateInProgress = "inProgress"
  DownloadProgressStateCompleted  = "completed"
  DownloadProgressStateCanceled   = "canceled"

  alias SetDownloadBehaviorBehavior = String
  SetDownloadBehaviorBehaviorDeny         = "deny"
  SetDownloadBehaviorBehaviorAllow        = "allow"
  SetDownloadBehaviorBehaviorAllowAndName = "allowAndName"
  SetDownloadBehaviorBehaviorDefault      = "default"
end
