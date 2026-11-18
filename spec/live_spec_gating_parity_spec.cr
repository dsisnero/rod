require "./spec_helper"

# A live parity spec that hides behind an env flag never runs in the suite, so a
# regression in the ported behavior goes unnoticed: go-rod runs every test in
# `go test ./...` without opt-in switches. The Chrome-dependent examples already
# guard themselves with `RodSpec.chrome_available?`, which is a machine
# capability check rather than a per-run opt-in.
describe "live spec gating parity" do
  it "runs every live parity example without an env opt-in" do
    gated = Dir.glob(File.join(__DIR__, "*_spec.cr")).select do |path|
      next false if path == __FILE__

      File.read(path).includes?("ROD_REAL_BROWSER")
    end

    gated.should be_empty
  end
end
