require "../cdp"
require "json"
require "time"

require "./types"
require "./events"

# This domain allows configuring virtual authenticators to test the WebAuthn
# API.
@[Experimental]
module Cdp::WebAuthn
  struct AddVirtualAuthenticatorResult
    include JSON::Serializable
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId

    def initialize(@authenticator_id : AuthenticatorId)
    end
  end

  struct GetCredentialResult
    include JSON::Serializable
    @[JSON::Field(key: "credential", emit_null: false)]
    property credential : Credential

    def initialize(@credential : Credential)
    end
  end

  struct GetCredentialsResult
    include JSON::Serializable
    @[JSON::Field(key: "credentials", emit_null: false)]
    property credentials : Array(Credential)

    def initialize(@credentials : Array(Credential))
    end
  end

  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enableUi", emit_null: false)]
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
    @[JSON::Field(key: "options", emit_null: false)]
    property options : VirtualAuthenticatorOptions

    def initialize(@options : VirtualAuthenticatorOptions)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "isBogusSignature", emit_null: false)]
    property? is_bogus_signature : Bool?
    @[JSON::Field(key: "isBadUv", emit_null: false)]
    property? is_bad_uv : Bool?
    @[JSON::Field(key: "isBadUp", emit_null: false)]
    property? is_bad_up : Bool?

    def initialize(@authenticator_id : AuthenticatorId, @is_bogus_signature : Bool?, @is_bad_uv : Bool?, @is_bad_up : Bool?)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId

    def initialize(@authenticator_id : AuthenticatorId)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "credential", emit_null: false)]
    property credential : Credential

    def initialize(@authenticator_id : AuthenticatorId, @credential : Credential)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "credentialId", emit_null: false)]
    property credential_id : String

    def initialize(@authenticator_id : AuthenticatorId, @credential_id : String)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId

    def initialize(@authenticator_id : AuthenticatorId)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "credentialId", emit_null: false)]
    property credential_id : String

    def initialize(@authenticator_id : AuthenticatorId, @credential_id : String)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId

    def initialize(@authenticator_id : AuthenticatorId)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "isUserVerified", emit_null: false)]
    property? is_user_verified : Bool

    def initialize(@authenticator_id : AuthenticatorId, @is_user_verified : Bool)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool

    def initialize(@authenticator_id : AuthenticatorId, @enabled : Bool)
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
    @[JSON::Field(key: "authenticatorId", emit_null: false)]
    property authenticator_id : AuthenticatorId
    @[JSON::Field(key: "credentialId", emit_null: false)]
    property credential_id : String
    @[JSON::Field(key: "backupEligibility", emit_null: false)]
    property? backup_eligibility : Bool?
    @[JSON::Field(key: "backupState", emit_null: false)]
    property? backup_state : Bool?

    def initialize(@authenticator_id : AuthenticatorId, @credential_id : String, @backup_eligibility : Bool?, @backup_state : Bool?)
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
