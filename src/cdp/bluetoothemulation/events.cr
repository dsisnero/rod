require "../cdp"
require "json"
require "time"

module Cdp::BluetoothEmulation
  struct GattOperationReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "address", emit_null: false)]
    property address : String
    @[JSON::Field(key: "type", emit_null: false)]
    property type : GATTOperationType

    def initialize(@address : String, @type : GATTOperationType)
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
    @[JSON::Field(key: "characteristicId", emit_null: false)]
    property characteristic_id : String
    @[JSON::Field(key: "type", emit_null: false)]
    property type : CharacteristicOperationType
    @[JSON::Field(key: "data", emit_null: false)]
    property data : String?
    @[JSON::Field(key: "writeType", emit_null: false)]
    property write_type : CharacteristicWriteType?

    def initialize(@characteristic_id : String, @type : CharacteristicOperationType, @data : String?, @write_type : CharacteristicWriteType?)
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
    @[JSON::Field(key: "descriptorId", emit_null: false)]
    property descriptor_id : String
    @[JSON::Field(key: "type", emit_null: false)]
    property type : DescriptorOperationType
    @[JSON::Field(key: "data", emit_null: false)]
    property data : String?

    def initialize(@descriptor_id : String, @type : DescriptorOperationType, @data : String?)
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
