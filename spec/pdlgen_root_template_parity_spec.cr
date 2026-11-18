require "spec"
require "../src/pdlgen/gen"

# `src/cdp/cdp.cr` is the hand-maintained root module: `Cdp.call`, the client
# interface, the timestamp normalization and the protocol error helpers. The
# generator used to emit a stale partial root, so `make generate-crystal` had to
# save and restore that file after every run. This spec pins the template to the
# committed file so a regeneration is a no-op.
describe "pdlgen root template parity" do
  it "renders the committed root module byte for byte" do
    files = Pdlgen::Gen::CrystalTemplateGenerator.create([] of Pdlgen::Pdl::Domain, "Cdp").emit
    rendered = files["cdp.cr"]?
    rendered.should_not be_nil
    rendered = rendered.not_nil!

    committed = File.read(File.join(__DIR__, "..", "src", "cdp", "cdp.cr"))
    rendered.should eq(committed)
  end

  it "keeps the curated API surface in the template" do
    rendered = Pdlgen::Gen::CrystalTemplateGenerator.create([] of Pdlgen::Pdl::Domain, "Cdp").emit["cdp.cr"].not_nil!

    # Root-level helpers the port relies on.
    rendered.should contain("TIME_FIELD_KEYS = {")
    rendered.should contain("module JSON::Serializable")
    rendered.should contain("def self.normalize_incoming(node : JSON::Any) : JSON::Any")
    rendered.should contain("def self.pattern_to_reg(pattern : String) : String")
    rendered.should contain("def self.call(method : String, req : Request, res_class : T.class, c : Client) : T forall T")
    rendered.should contain("def self.call(method : String, req : Request, res : JSON::Serializable?, c : Client) : Nil")
    rendered.should contain("abstract class Client")
    rendered.should contain("module Sessionable")
    rendered.should contain("module Contextable")
    rendered.should contain("module Request")
    rendered.should contain("module Event")
    # Error parity: data field, Go-style string form and `is?`.
    rendered.should contain("property data : JSON::Any?")
    rendered.should contain("def is?(other : Error) : Bool")
    rendered.should contain(%("{\#{code} \#{message} \#{data_str}}"))
    rendered.should contain("ErrObjNotFound")
    rendered.should contain("ErrNotAttachedToActivePage")
  end
end
