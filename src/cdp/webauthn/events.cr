require "../webauthn/webauthn"
require "json"
require "time"

module Cdp::WebAuthn
  struct CredentialAddedEvent
    include JSON::Serializable
    include Cdp::Event

    property authenticator_id : AuthenticatorId
    property credential : Credential

    def initialize(@authenticator_id : AuthenticatorId, @credential : Credential)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAuthn.credentialAdded"
    end
  end

  struct CredentialDeletedEvent
    include JSON::Serializable
    include Cdp::Event

    property authenticator_id : AuthenticatorId
    property credential_id : String

    def initialize(@authenticator_id : AuthenticatorId, @credential_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAuthn.credentialDeleted"
    end
  end

  struct CredentialUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    property authenticator_id : AuthenticatorId
    property credential : Credential

    def initialize(@authenticator_id : AuthenticatorId, @credential : Credential)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAuthn.credentialUpdated"
    end
  end

  struct CredentialAssertedEvent
    include JSON::Serializable
    include Cdp::Event

    property authenticator_id : AuthenticatorId
    property credential : Credential

    def initialize(@authenticator_id : AuthenticatorId, @credential : Credential)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAuthn.credentialAsserted"
    end
  end
end
