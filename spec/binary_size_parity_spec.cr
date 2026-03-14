require "./spec_helper"

describe "binary size parity" do
  it "matches TestBinarySize behavior" do
    if Rod::Util::Launcher.in_container?
      # Upstream gate: skip in containerized environments.
      true.should be_true
      next
    end

    Dir.mkdir_p("tmp")

    env = ENV.to_h
    env["CRYSTAL_CACHE_DIR"] = File.expand_path(".crystal-cache", Dir.current)
    status = Process.run(
      "crystal",
      args: ["build", "lib/examples/translator/main.cr", "--release", "-o", "tmp/translator"],
      env: env
    )
    status.success?.should be_true

    size_mb = File.info("tmp/translator").size.to_f / 1024 / 1024
    size_mb.should be <= 11.0
  end
end
