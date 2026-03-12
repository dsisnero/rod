require "../cdp"
require "json"

# Database domain (deprecated in CDP, retained for Go proto compatibility).
module Cdp::Database
  alias DatabaseId = String

  struct Database
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : DatabaseId
    @[JSON::Field(key: "domain", emit_null: false)]
    property domain : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String

    def initialize(@id : DatabaseId, @domain : String, @name : String, @version : String)
    end
  end

  struct Error
    include JSON::Serializable
    @[JSON::Field(key: "message", emit_null: false)]
    property message : String
    @[JSON::Field(key: "code", emit_null: false)]
    property code : Int32

    def initialize(@message : String, @code : Int32)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    def proto_req : String
      "Database.disable"
    end

    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    def proto_req : String
      "Database.enable"
    end

    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ExecuteSQL
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "databaseId", emit_null: false)]
    property database_id : DatabaseId
    @[JSON::Field(key: "query", emit_null: false)]
    property query : String

    def initialize(@database_id : DatabaseId, @query : String)
    end

    def proto_req : String
      "Database.executeSQL"
    end

    def call(c : Cdp::Client) : ExecuteSQLResult
      Cdp.call(proto_req, self, ExecuteSQLResult, c)
    end
  end

  struct ExecuteSQLResult
    include JSON::Serializable
    @[JSON::Field(key: "columnNames", emit_null: false)]
    property column_names : Array(String)?
    @[JSON::Field(key: "values", emit_null: false)]
    property values : Array(JSON::Any)?
    @[JSON::Field(key: "sqlError", emit_null: false)]
    property sql_error : Error?

    def initialize(@column_names : Array(String)? = nil, @values : Array(JSON::Any)? = nil, @sql_error : Error? = nil)
    end
  end

  struct GetDatabaseTableNames
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "databaseId", emit_null: false)]
    property database_id : DatabaseId

    def initialize(@database_id : DatabaseId)
    end

    def proto_req : String
      "Database.getDatabaseTableNames"
    end

    def call(c : Cdp::Client) : GetDatabaseTableNamesResult
      Cdp.call(proto_req, self, GetDatabaseTableNamesResult, c)
    end
  end

  struct GetDatabaseTableNamesResult
    include JSON::Serializable
    @[JSON::Field(key: "tableNames", emit_null: false)]
    property table_names : Array(String)

    def initialize(@table_names : Array(String))
    end
  end

  struct AddDatabase
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "database", emit_null: false)]
    property database : Database

    def initialize(@database : Database)
    end

    def proto_event : String
      "Database.addDatabase"
    end

    def self.proto_event : String
      "Database.addDatabase"
    end
  end
end
