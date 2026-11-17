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
end
