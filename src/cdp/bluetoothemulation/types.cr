require "../cdp"
require "json"
require "time"

module Cdp::BluetoothEmulation
  alias CentralState = String
  CentralStateAbsent     = "absent"
  CentralStatePoweredOff = "powered-off"
  CentralStatePoweredOn  = "powered-on"

  alias GATTOperationType = String
  GATTOperationTypeConnection = "connection"
  GATTOperationTypeDiscovery  = "discovery"

  alias CharacteristicWriteType = String
  CharacteristicWriteTypeWriteDefaultDeprecated = "write-default-deprecated"
  CharacteristicWriteTypeWriteWithResponse      = "write-with-response"
  CharacteristicWriteTypeWriteWithoutResponse   = "write-without-response"

  alias CharacteristicOperationType = String
  CharacteristicOperationTypeRead                         = "read"
  CharacteristicOperationTypeWrite                        = "write"
  CharacteristicOperationTypeSubscribeToNotifications     = "subscribe-to-notifications"
  CharacteristicOperationTypeUnsubscribeFromNotifications = "unsubscribe-from-notifications"

  alias DescriptorOperationType = String
  DescriptorOperationTypeRead  = "read"
  DescriptorOperationTypeWrite = "write"

  struct ManufacturerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : Int64
    @[JSON::Field(emit_null: false)]
    property data : String
  end

  struct ScanRecord
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property uuids : Array(String)?
    @[JSON::Field(emit_null: false)]
    property appearance : Int64?
    @[JSON::Field(emit_null: false)]
    property tx_power : Int64?
    @[JSON::Field(emit_null: false)]
    property manufacturer_data : Array(ManufacturerData)?
  end

  struct ScanEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property device_address : String
    @[JSON::Field(emit_null: false)]
    property rssi : Int64
    @[JSON::Field(emit_null: false)]
    property scan_record : ScanRecord
  end

  struct CharacteristicProperties
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? broadcast : Bool?
    @[JSON::Field(emit_null: false)]
    property? read : Bool?
    @[JSON::Field(emit_null: false)]
    property? write_without_response : Bool?
    @[JSON::Field(emit_null: false)]
    property? write : Bool?
    @[JSON::Field(emit_null: false)]
    property? notify : Bool?
    @[JSON::Field(emit_null: false)]
    property? indicate : Bool?
    @[JSON::Field(emit_null: false)]
    property? authenticated_signed_writes : Bool?
    @[JSON::Field(emit_null: false)]
    property? extended_properties : Bool?
  end
end
