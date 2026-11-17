require "spec"
require "../src/pdlgen/util"

# Characterization specs for the Chromium `DEPS` → V8 version lookup used by
# pdlgen (`getDepVersion` in Go's cdproto-gen). Both lookups search raw file
# bytes and decode gitiles refs JSON, and both silently diverged from Go:
# `Bytes#index(String)` never matches, and gitiles refs entries without a
# `target` (lightweight refs) used to raise instead of decoding to "".
private def write_pdlgen_fixture(dir : String, name : String, content : String) : String
  Dir.mkdir_p(dir)
  path = File.join(dir, name)
  File.write(path, content)
  path
end

private def pdlgen_cache(path : String) : Pdlgen::Util::Cache
  Pdlgen::Util::Cache.new(url: "file:///dev/null", path: path, ttl: 1.hour)
end

# Mirrors the gclient DEPS syntax used by Chromium tags.
private DEPS_FIXTURE = "deps = {\n" \
                       "  'src/build': 'https://chromium.googlesource.com/chromium/src/build.git@abc123',\n" \
                       "  'v8_revision': '251630153c1f0ed8736b4fd06e0105cb5355d37c',\n" \
                       "  'src/third_party/zlib': 'https://example.com/zlib.git@def456',\n" \
                       "}\n"

# gitiles emits an XSSI prefix line before the JSON body.
private REFS_FIXTURE = ")]}'\n" \
                       "{\"refs/tags/16.0.73\": {\"value\": \"251630153c1f0ed8736b4fd06e0105cb5355d37c\", \"target\": \"aaaa1111\"},\n" \
                       " \"refs/heads/main\": {\"value\": \"9999888877776666\"}}\n"

describe Pdlgen::Util do
  describe ".get_dep_version" do
    it "reads the dependency revision out of the Chromium DEPS file" do
      deps_path = write_pdlgen_fixture("temp/pdlgen_util_parity/deps", "DEPS", DEPS_FIXTURE)
      refs_path = write_pdlgen_fixture("temp/pdlgen_util_parity/deps", "refs.json", REFS_FIXTURE)

      version = Pdlgen::Util.get_dep_version(
        "v8",
        "160.0.8168.1",
        pdlgen_cache(deps_path),
        pdlgen_cache(refs_path)
      )

      version.should eq("16.0.73")
    end

    it "raises when the DEPS file has no matching revision" do
      deps_path = write_pdlgen_fixture(
        "temp/pdlgen_util_parity/deps_missing",
        "DEPS",
        "deps = {\n  'src/build': 'https://example.com/build.git@abc123',\n}\n"
      )
      refs_path = write_pdlgen_fixture("temp/pdlgen_util_parity/deps_missing", "refs.json", ")]}'\n{}\n")

      expect_raises(Exception, /could not find revision for v8 version 160.0.8168.1/) do
        Pdlgen::Util.get_dep_version(
          "v8",
          "160.0.8168.1",
          pdlgen_cache(deps_path),
          pdlgen_cache(refs_path)
        )
      end
    end
  end

  describe ".get_refs" do
    it "decodes gitiles refs and tolerates entries without a target" do
      refs_path = write_pdlgen_fixture("temp/pdlgen_util_parity/refs", "refs.json", REFS_FIXTURE)

      refs = Pdlgen::Util.get_refs(pdlgen_cache(refs_path))

      refs["refs/tags/16.0.73"].value.should eq("251630153c1f0ed8736b4fd06e0105cb5355d37c")
      refs["refs/tags/16.0.73"].target.should eq("aaaa1111")
      # Go decodes a missing `target` into the zero value instead of failing.
      refs["refs/heads/main"].value.should eq("9999888877776666")
      refs["refs/heads/main"].target.should eq("")
    end
  end
end
