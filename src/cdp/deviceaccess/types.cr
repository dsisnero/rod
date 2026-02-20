require "../deviceaccess/deviceaccess"
require "json"
require "time"

module Cdp::DeviceAccess
  alias RequestId = String

  alias DeviceId = String

  struct PromptDevice
    include JSON::Serializable

    property id : DeviceId
    property name : String
  end
end
