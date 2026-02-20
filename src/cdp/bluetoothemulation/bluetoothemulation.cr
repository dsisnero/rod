require "json"
require "../cdp"
require "./types"

# This domain allows configuring virtual Bluetooth devices to test
# the web-bluetooth API.
@[Experimental]
module Cdp::BluetoothEmulation
  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request

    property state : CentralState
    property le_supported : Bool

    def initialize(@state : CentralState, @le_supported : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetSimulatedCentralState
    include JSON::Serializable
    include Cdp::Request

    property state : CentralState

    def initialize(@state : CentralState)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.setSimulatedCentralState"
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
      "BluetoothEmulation.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulatePreconnectedPeripheral
    include JSON::Serializable
    include Cdp::Request

    property address : String
    property name : String
    property manufacturer_data : Array(ManufacturerData)
    property known_service_uuids : Array(String)

    def initialize(@address : String, @name : String, @manufacturer_data : Array(ManufacturerData), @known_service_uuids : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.simulatePreconnectedPeripheral"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulateAdvertisement
    include JSON::Serializable
    include Cdp::Request

    property entry : ScanEntry

    def initialize(@entry : ScanEntry)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.simulateAdvertisement"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulateGATTOperationResponse
    include JSON::Serializable
    include Cdp::Request

    property address : String
    property type : GATTOperationType
    property code : Int64

    def initialize(@address : String, @type : GATTOperationType, @code : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.simulateGATTOperationResponse"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulateCharacteristicOperationResponse
    include JSON::Serializable
    include Cdp::Request

    property characteristic_id : String
    property type : CharacteristicOperationType
    property code : Int64
    @[JSON::Field(emit_null: false)]
    property data : String?

    def initialize(@characteristic_id : String, @type : CharacteristicOperationType, @code : Int64, @data : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.simulateCharacteristicOperationResponse"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulateDescriptorOperationResponse
    include JSON::Serializable
    include Cdp::Request

    property descriptor_id : String
    property type : DescriptorOperationType
    property code : Int64
    @[JSON::Field(emit_null: false)]
    property data : String?

    def initialize(@descriptor_id : String, @type : DescriptorOperationType, @code : Int64, @data : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.simulateDescriptorOperationResponse"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddService
    include JSON::Serializable
    include Cdp::Request

    property address : String
    property service_uuid : String

    def initialize(@address : String, @service_uuid : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.addService"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddServiceResult
      res = AddServiceResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct AddServiceResult
    include JSON::Serializable

    property service_id : String

    def initialize(@service_id : String)
    end
  end

  struct RemoveService
    include JSON::Serializable
    include Cdp::Request

    property service_id : String

    def initialize(@service_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.removeService"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddCharacteristic
    include JSON::Serializable
    include Cdp::Request

    property service_id : String
    property characteristic_uuid : String
    property properties : CharacteristicProperties

    def initialize(@service_id : String, @characteristic_uuid : String, @properties : CharacteristicProperties)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.addCharacteristic"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddCharacteristicResult
      res = AddCharacteristicResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct AddCharacteristicResult
    include JSON::Serializable

    property characteristic_id : String

    def initialize(@characteristic_id : String)
    end
  end

  struct RemoveCharacteristic
    include JSON::Serializable
    include Cdp::Request

    property characteristic_id : String

    def initialize(@characteristic_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.removeCharacteristic"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddDescriptor
    include JSON::Serializable
    include Cdp::Request

    property characteristic_id : String
    property descriptor_uuid : String

    def initialize(@characteristic_id : String, @descriptor_uuid : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.addDescriptor"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddDescriptorResult
      res = AddDescriptorResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct AddDescriptorResult
    include JSON::Serializable

    property descriptor_id : String

    def initialize(@descriptor_id : String)
    end
  end

  struct RemoveDescriptor
    include JSON::Serializable
    include Cdp::Request

    property descriptor_id : String

    def initialize(@descriptor_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.removeDescriptor"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulateGATTDisconnection
    include JSON::Serializable
    include Cdp::Request

    property address : String

    def initialize(@address : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "BluetoothEmulation.simulateGATTDisconnection"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
