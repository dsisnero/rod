require "spec"
require "../src/pdlgen/gen"

# CDP serializes fields under their protocol (camelCase) names, while the
# emitter exposes Crystal (snake_case) properties. Without an explicit
# `JSON::Field(key:)` every property decodes as nil, so these specs pin the wire
# key on types, event parameters, command parameters and command returns.
private def json_key_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Probe", "Emitter wire-key probe")

  widget = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Widget",
    raw_type: "type",
    raw_name: "Probe.Widget",
    description: "A widget."
  )
  widget.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Number,
      name: "requestTime",
      raw_name: "Probe.Widget.requestTime",
      description: "Timestamp."
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "url",
      raw_name: "Probe.Widget.url",
      description: "Single-word name."
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Boolean,
      name: "hasFocus",
      raw_name: "Probe.Widget.hasFocus",
      description: "Boolean flag.",
      optional: true
    ),
  ]
  domain.types << widget

  event = Pdlgen::Pdl::Type.new(
    raw_type: "event",
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "WidgetFired",
    raw_name: "Probe.WidgetFired",
    description: "Fired when the widget fires."
  )
  event.parameters = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "frameId",
      raw_name: "Probe.WidgetFired.frameId",
      description: "Frame id."
    ),
  ]
  domain.events << event

  command = Pdlgen::Pdl::Type.new(
    raw_type: "command",
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "DoThing",
    raw_name: "Probe.DoThing",
    description: "Does the thing."
  )
  command.parameters = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "requestId",
      raw_name: "Probe.DoThing.requestId",
      description: "Request id."
    ),
  ]
  command.returns = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "resultText",
      raw_name: "Probe.DoThing.resultText",
      description: "Result text."
    ),
  ]
  domain.commands << command

  domain
end

private def annotated_fields_without_key(files : Hash(String, String)) : Array(String)
  files.flat_map do |name, source|
    source.lines.select { |line| line.includes?("JSON::Field(emit_null: false)") && !line.includes?("key: ") }
      .map { |line| "#{name}: #{line.strip}" }
  end
end

describe "pdlgen JSON wire keys" do
  it "annotates every field with its protocol key" do
    files = Pdlgen::Gen::CrystalTemplateGenerator.create([json_key_fixture], "Cdp").emit

    annotated_fields_without_key(files).should eq([] of String)
  end

  it "uses the protocol name, not the Crystal property name, for the key" do
    files = Pdlgen::Gen::CrystalTemplateGenerator.create([json_key_fixture], "Cdp").emit
    types = files["probe/types.cr"].not_nil!

    types.should contain(%(@[JSON::Field(key: "requestTime", emit_null: false)]\n    property request_time : Float64))
    types.should contain(%(@[JSON::Field(key: "url", emit_null: false)]\n    property url : String))
    types.should contain(%(@[JSON::Field(key: "hasFocus", emit_null: false)]\n    property? has_focus : Bool?))
  end

  it "annotates event parameters and command parameters/returns" do
    files = Pdlgen::Gen::CrystalTemplateGenerator.create([json_key_fixture], "Cdp").emit
    events = files["probe/events.cr"].not_nil!
    commands = files["probe/probe.cr"].not_nil!

    events.should contain(%(@[JSON::Field(key: "frameId", emit_null: false)]))
    commands.should contain(%(@[JSON::Field(key: "requestId", emit_null: false)]))
    commands.should contain(%(@[JSON::Field(key: "resultText", emit_null: false)]))
  end
end
