require "./spec_helper"

describe "utils template parity" do
  it "renders key/value, nested field, and function tokens" do
    out = Rod::Util::Utils.s(
      "{{.a}} {{.b}} {{.c.A}} {{d}}",
      "a", "<value>",
      "b", 10,
      "c", {"A" => "ok"},
      "d", -> { "ok" }
    )

    out.should eq("<value> 10 ok ok")
  end
end
