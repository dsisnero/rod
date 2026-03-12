require "./spec_helper"
require "../src/cdp/console/console"
require "../src/cdp/database/database"
require "../src/cdp/schema/schema"

private class LegacyProtoClient < Cdp::Client
  getter calls = [] of String
  getter params = [] of JSON::Any

  def initialize
    @responses = {} of String => String
  end

  def stub(method : String, payload : String) : Nil
    @responses[method] = payload
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    @calls << method
    @params << params
    (@responses[method]? || %({})).to_slice
  end
end

describe "legacy proto domain parity" do
  it "implements Console request and event protocol names" do
    client = LegacyProtoClient.new
    Cdp::Console::Enable.new.call(client)
    Cdp::Console::Disable.new.call(client)
    Cdp::Console::ClearMessages.new.call(client)

    client.calls.should eq(["Console.enable", "Console.disable", "Console.clearMessages"])
    Cdp::Console::MessageAdded.proto_event.should eq("Console.messageAdded")
  end

  it "decodes Database command results" do
    client = LegacyProtoClient.new
    client.stub("Database.executeSQL", %({"columnNames":["a"],"values":[1]}))
    client.stub("Database.getDatabaseTableNames", %({"tableNames":["users","orders"]}))

    sql = Cdp::Database::ExecuteSQL.new("db-1", "select 1")
    sql_result = sql.call(client)
    sql_result.column_names.not_nil!.should eq(["a"])
    sql_result.values.not_nil!.first.as_i.should eq(1)

    table_result = Cdp::Database::GetDatabaseTableNames.new("db-1").call(client)
    table_result.table_names.should eq(["users", "orders"])
  end

  it "decodes Schema.getDomains result" do
    client = LegacyProtoClient.new
    client.stub("Schema.getDomains", %({"domains":[{"name":"Page","version":"1.3"}]}))

    result = Cdp::Schema::GetDomains.new.call(client)
    result.domains.size.should eq(1)
    result.domains.first.name.should eq("Page")
    result.domains.first.version.should eq("1.3")
  end
end
