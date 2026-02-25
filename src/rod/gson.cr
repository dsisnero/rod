module Gson
  # JSON alias for JSON::Any
  alias JSON = ::JSON::Any

  # Create a new JSON value from any serializable value.
  def self.new(value : ::JSON::Serializable | ::JSON::Type) : JSON
    ::JSON::Any.new(value)
  end

  # Create a new JSON value from a raw JSON string.
  def self.new_from(json : String) : JSON
    ::JSON.parse(json)
  end

  # Create a JSON integer.
  def self.int(value : Int) : JSON
    ::JSON::Any.new(value)
  end

  # Create a JSON float.
  def self.num(value : Float64) : JSON
    ::JSON::Any.new(value)
  end

  # Create a JSON boolean.
  def self.bool(value : Bool) : JSON
    ::JSON::Any.new(value)
  end

  # Create a JSON string.
  def self.str(value : String) : JSON
    ::JSON::Any.new(value)
  end

  # Create a JSON null.
  def self.null : JSON
    ::JSON::Any.new(nil)
  end
end
