require "json"
require "../cdp"
require "./types"

# This domain allows interacting with the FedCM dialog.
@[Experimental]
module Cdp::FedCm
  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property disable_rejection_delay : Bool?

    def initialize(@disable_rejection_delay : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SelectAccount
    include JSON::Serializable
    include Cdp::Request

    property dialog_id : String
    property account_index : Int64

    def initialize(@dialog_id : String, @account_index : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.selectAccount"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClickDialogButton
    include JSON::Serializable
    include Cdp::Request

    property dialog_id : String
    property dialog_button : DialogButton

    def initialize(@dialog_id : String, @dialog_button : DialogButton)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.clickDialogButton"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct OpenUrl
    include JSON::Serializable
    include Cdp::Request

    property dialog_id : String
    property account_index : Int64
    property account_url_type : AccountUrlType

    def initialize(@dialog_id : String, @account_index : Int64, @account_url_type : AccountUrlType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.openUrl"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DismissDialog
    include JSON::Serializable
    include Cdp::Request

    property dialog_id : String
    @[JSON::Field(emit_null: false)]
    property trigger_cooldown : Bool?

    def initialize(@dialog_id : String, @trigger_cooldown : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.dismissDialog"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ResetCooldown
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "FedCm.resetCooldown"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
