require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# This domain allows configuring virtual authenticators to test the WebAuthn
# API.
@[Experimental]
module Cdp::WebAuthn
  struct AddVirtualAuthenticatorResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType

    def initialize(@authenticator_id : Cdp::NodeType)
    end
  end

  struct GetCredentialResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property credential : Cdp::NodeType

    def initialize(@credential : Cdp::NodeType)
    end
  end

  struct GetCredentialsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property credentials : Array(Cdp::NodeType)

    def initialize(@credentials : Array(Cdp::NodeType))
    end
  end

  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable_ui : Bool?

    def initialize(@enable_ui : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.enable"
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
      "WebAuthn.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddVirtualAuthenticator
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property options : Cdp::NodeType

    def initialize(@options : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.addVirtualAuthenticator"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddVirtualAuthenticatorResult
      res = AddVirtualAuthenticatorResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetResponseOverrideBits
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_bogus_signature : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_bad_uv : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_bad_up : Bool?

    def initialize(@authenticator_id : Cdp::NodeType, @is_bogus_signature : Bool?, @is_bad_uv : Bool?, @is_bad_up : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.setResponseOverrideBits"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveVirtualAuthenticator
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType

    def initialize(@authenticator_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.removeVirtualAuthenticator"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddCredential
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property credential : Cdp::NodeType

    def initialize(@authenticator_id : Cdp::NodeType, @credential : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.addCredential"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetCredential
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property credential_id : String

    def initialize(@authenticator_id : Cdp::NodeType, @credential_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.getCredential"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCredentialResult
      res = GetCredentialResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetCredentials
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType

    def initialize(@authenticator_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.getCredentials"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCredentialsResult
      res = GetCredentialsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RemoveCredential
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property credential_id : String

    def initialize(@authenticator_id : Cdp::NodeType, @credential_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.removeCredential"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearCredentials
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType

    def initialize(@authenticator_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.clearCredentials"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetUserVerified
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_user_verified : Bool

    def initialize(@authenticator_id : Cdp::NodeType, @is_user_verified : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.setUserVerified"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetAutomaticPresenceSimulation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

    def initialize(@authenticator_id : Cdp::NodeType, @enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.setAutomaticPresenceSimulation"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetCredentialProperties
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property authenticator_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property credential_id : String
    @[JSON::Field(emit_null: false)]
    property? backup_eligibility : Bool?
    @[JSON::Field(emit_null: false)]
    property? backup_state : Bool?

    def initialize(@authenticator_id : Cdp::NodeType, @credential_id : String, @backup_eligibility : Bool?, @backup_state : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAuthn.setCredentialProperties"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
