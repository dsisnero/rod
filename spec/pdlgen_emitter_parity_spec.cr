require "spec"
require "../src/pdlgen/gen"

# Characterization specs for the Crystal emitter's protocol-construct handling.
# Both cases below emit Crystal that does not compile when they regress, so they
# guard the generator rather than the committed `src/cdp` tree.
private def fetch_enum_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Fetch", "Network request interception")

  challenge = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "AuthChallenge",
    raw_type: "type",
    raw_name: "Fetch.AuthChallenge",
    description: "Authorization challenge for HTTP authentication."
  )
  challenge.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "origin",
      raw_name: "Fetch.AuthChallenge.origin",
      description: "The origin of the challenge."
    ),
    # Inline enum property: the Go generator lifts it into a `AuthChallengeSource`
    # domain type (see `fixup_enum_parameter`).
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "source",
      raw_name: "Fetch.AuthChallenge.source",
      description: "Source of the authentication challenge.",
      enum: ["Server", "Proxy"]
    ),
  ]
  domain.types << challenge
  domain
end

private def command_param_order_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Probe", "Emitter ordering probe")

  command = Pdlgen::Pdl::Type.new(
    raw_type: "command",
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "DoThing",
    raw_name: "Probe.DoThing",
    description: "Runs the thing."
  )
  # Protocol order: an optional parameter followed by a required one. Crystal
  # rejects a parameter without a default that follows one that has a default.
  command.parameters = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "optionalFirst",
      raw_name: "Probe.DoThing.optionalFirst",
      description: "Optional.",
      optional: true
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "requiredSecond",
      raw_name: "Probe.DoThing.requiredSecond",
      description: "Required."
    ),
  ]
  domain.commands << command
  domain
end

private def recursive_type_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Probe", "Emitter recursion probe")

  # Self-referential: Runtime.StackTrace.parent.
  trace = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Trace",
    raw_type: "type",
    raw_name: "Probe.Trace",
    description: "A trace with an optional parent trace."
  )
  trace.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "description",
      raw_name: "Probe.Trace.description",
      description: "Description."
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Object,
      name: "parent",
      raw_name: "Probe.Trace.parent",
      ref: "Probe.Trace",
      description: "Parent trace.",
      optional: true
    ),
  ]
  domain.types << trace

  # Mutually recursive pair: Ping -> Pong -> Ping.
  ping = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Ping",
    raw_type: "type",
    raw_name: "Probe.Ping",
    description: "Half of a recursive pair."
  )
  ping.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Object,
      name: "pong",
      raw_name: "Probe.Ping.pong",
      ref: "Probe.Pong",
      description: "The other half.",
      optional: true
    ),
  ]
  domain.types << ping

  pong = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Pong",
    raw_type: "type",
    raw_name: "Probe.Pong",
    description: "Half of a recursive pair."
  )
  pong.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Object,
      name: "ping",
      raw_name: "Probe.Pong.ping",
      ref: "Probe.Ping",
      description: "The other half.",
      optional: true
    ),
  ]
  domain.types << pong

  # Non-recursive control: a struct must stay a struct.
  widget = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Widget",
    raw_type: "type",
    raw_name: "Probe.Widget",
    description: "A non-recursive value type."
  )
  widget.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "label",
      raw_name: "Probe.Widget.label",
      description: "Label."
    ),
  ]
  domain.types << widget

  domain
end

private def runtime_only_field_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Probe", "Emitter runtime-only field probe")

  holder = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Holder",
    raw_type: "type",
    raw_name: "Probe.Holder",
    description: "Carries runtime-only state beside protocol fields."
  )
  holder.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "label",
      raw_name: "Probe.Holder.label",
      description: "Protocol field."
    ),
    # go-rod adds struct-only fields (channels, mutexes, state flags) that are
    # not part of the wire format; they must not be decoded.
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Any,
      name: "Invalidated",
      ref: "Channel(Nil)",
      description: "Invalidated channel.",
      no_resolve: true,
      no_expose: true,
      default_value: "Channel(Nil).new(1)"
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Any,
      name: "mutex",
      ref: "Mutex",
      description: "Read write mutex.",
      no_resolve: true,
      no_expose: true,
      default_value: "Mutex.new"
    ),
  ]
  domain.types << holder
  domain
end

private def value_type_constructor_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Probe", "Emitter value-type constructor probe")

  pair = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Pair",
    raw_type: "type",
    raw_name: "Probe.Pair",
    description: "A value type with mixed required and optional fields."
  )
  pair.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Number,
      name: "x",
      raw_name: "Probe.Pair.x",
      description: "First coordinate."
    ),
    # Optional-then-required is the protocol's usual order; Crystal needs the
    # required parameters first.
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "label",
      raw_name: "Probe.Pair.label",
      description: "Optional label.",
      optional: true
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Number,
      name: "y",
      raw_name: "Probe.Pair.y",
      description: "Second coordinate."
    ),
  ]
  domain.types << pair

  viewport = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Viewport",
    raw_type: "type",
    raw_name: "Probe.Viewport",
    description: "A type with a curated default."
  )
  viewport.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Number,
      name: "width",
      raw_name: "Probe.Viewport.width",
      description: "Width."
    ),
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::Number,
      name: "scale",
      raw_name: "Probe.Viewport.scale",
      description: "Scale.",
      default_value: "1.0"
    ),
  ]
  domain.types << viewport

  domain
end

private def extra_placement_fixture : Pdlgen::Pdl::Domain
  domain = Pdlgen::Pdl::Domain.new("Probe", "Emitter extra placement probe")

  holder = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Holder",
    raw_type: "type",
    raw_name: "Probe.Holder",
    description: "Carries a member helper.",
    extra: "def member_helper : String\n  \"helper\"\nend",
    extra_in_type: true
  )
  holder.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "label",
      raw_name: "Probe.Holder.label",
      description: "Label."
    ),
  ]
  domain.types << holder

  other = Pdlgen::Pdl::Type.new(
    type: Pdlgen::Pdl::TypeEnum::Object,
    name: "Other",
    raw_type: "type",
    raw_name: "Probe.Other",
    description: "Follows the holder.",
    extra: "MODULE_CONSTANT = 1"
  )
  other.properties = [
    Pdlgen::Pdl::Type.new(
      type: Pdlgen::Pdl::TypeEnum::String,
      name: "label",
      raw_name: "Probe.Other.label",
      description: "Label."
    ),
  ]
  domain.types << other

  domain
end

private def generate(domain : Pdlgen::Pdl::Domain) : Hash(String, String)
  Pdlgen::Gen::CrystalTemplateGenerator.create([domain], "Cdp").emit
end

describe "pdlgen Crystal emitter" do
  describe "inline enum types" do
    it "emits one alias per lifted enum type, without a domain qualifier" do
      files = generate(fetch_enum_fixture)
      types = files["fetch/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      # Exactly one definition, named after the type itself.
      types.scan(/alias AuthChallengeSource = String/).size.should eq(1)
      # No alias may carry a domain prefix — `alias Fetch.X` is not valid Crystal.
      types.should_not match(/alias [A-Za-z0-9_]+\./)
      types.should_not match(/alias [A-Za-z0-9_]+\./)
    end
  end

  describe "command constructors" do
    it "emits required parameters before optional ones" do
      files = generate(command_param_order_fixture)
      module_source = files["probe/probe.cr"]?

      module_source.should_not be_nil
      module_source = module_source.not_nil!

      initializer = module_source.lines.find(&.includes?("def initialize(")).to_s
      required_index = initializer.index("@required_second")
      optional_index = initializer.index("@optional_first")

      required_index.should_not be_nil
      optional_index.should_not be_nil
      required_index.not_nil!.should be < optional_index.not_nil!
    end
  end

  describe "recursive types" do
    # Crystal structs are laid out inline, so a type that contains itself
    # (directly or through another type) has no finite size. go-rod models
    # these fields as pointers, so the Crystal equivalent is a class.
    it "emits a class for self-referential types" do
      types = generate(recursive_type_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("class Trace")
      types.should_not contain("struct Trace")
    end

    it "emits a class for mutually recursive types" do
      types = generate(recursive_type_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("class Ping")
      types.should contain("class Pong")
    end

    it "keeps non-recursive types as structs" do
      types = generate(recursive_type_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("struct Widget")
      types.should_not contain("class Widget")
    end
  end

  describe "runtime-only fields" do
    # go-rod adds struct-only fields for internals (channels, mutexes). They are
    # not part of the protocol, so they must be excluded from JSON decoding and
    # carry an initializer default.
    it "ignores non-protocol fields and initializes them" do
      types = generate(runtime_only_field_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("@[JSON::Field(ignore: true)]\n    property invalidated : Channel(Nil) = Channel(Nil).new(1)")
      types.should contain("@[JSON::Field(ignore: true)]\n    property mutex : Mutex = Mutex.new")
      types.should_not contain(%(key: "Invalidated"))
      types.should_not contain(%(key: "mutex"))
      # Protocol fields keep their wire key.
      types.should contain(%(@[JSON::Field(key: "label", emit_null: false)]))
    end
  end

  describe "value type constructors" do
    # JSON::Serializable does not generate a keyword constructor, so a protocol
    # value type is unusable without one (`Point.new(1.0, 2.0)`).
    it "emits a constructor with required parameters first" do
      types = generate(value_type_constructor_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("def initialize(@x : Float64, @y : Float64, @label : String? = nil)")
    end

    it "keeps curated defaults on constructors" do
      types = generate(value_type_constructor_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("def initialize(@width : Float64, @scale : Float64 = 1.0)")
    end
  end

  describe "type extras" do
    # Member helpers must live inside the type body; module constants next to it.
    it "emits member extras inside the type and module extras at module scope" do
      types = generate(extra_placement_fixture)["probe/types.cr"]?

      types.should_not be_nil
      types = types.not_nil!

      types.should contain("struct Holder")
      before_other, after_other = types.split("struct Other", 2)
      before_other = before_other.not_nil!
      after_other = after_other.not_nil!

      before_other.should contain("def member_helper")
      after_other.should contain("MODULE_CONSTANT = 1")
    end
  end
end
