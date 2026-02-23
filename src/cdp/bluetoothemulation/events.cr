require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::BluetoothEmulation
  struct GattOperationReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property address : String
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType

    def initialize(@address : String, @type : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BluetoothEmulation.gattOperationReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "BluetoothEmulation.gattOperationReceived"
    end
  end

  struct CharacteristicOperationReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property characteristic_id : String
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property data : String?
    @[JSON::Field(emit_null: false)]
    property write_type : Cdp::NodeType?

    def initialize(@characteristic_id : String, @type : Cdp::NodeType, @data : String?, @write_type : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BluetoothEmulation.characteristicOperationReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "BluetoothEmulation.characteristicOperationReceived"
    end
  end

  struct DescriptorOperationReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property descriptor_id : String
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property data : String?

    def initialize(@descriptor_id : String, @type : Cdp::NodeType, @data : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BluetoothEmulation.descriptorOperationReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "BluetoothEmulation.descriptorOperationReceived"
    end
  end
end
