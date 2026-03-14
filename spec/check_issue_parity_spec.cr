require "./spec_helper"

describe "check issue parity" do
  it "matches TestBasic behavior" do
    ENV["GITHUB_TOKEN"] = "1234"

    invalid = File.read(File.expand_path("../vendor/rod/lib/utils/check-issue/body-invalid.txt", __DIR__))

    Rod::Util::CheckIssue.check(invalid).should eq(
      "Please add a valid `Rod Version: v0.0.0` to your issue. Current version is <nil>\n" \
      "\n" \
      "Please fix the format of your markdown:\n" \
      "\n" \
      "```txt\n" \
      "5 MD040/fenced-code-language Fenced code blocks should have a language specified [Context: \"```\"]\n" \
      "20:24 MD009/no-trailing-spaces Trailing spaces [Expected: 0 or 2; Actual: 1]\n" \
      "```\n" \
      "\n" \
      "Please fix the golang code in your markdown:\n" \
      "\n" \
      "```txt\n" \
      "@@ golang markdown block 1 @@\n" \
      "4:15: expected ';', found 'EOF'\n" \
      "4:15: expected '}', found 'EOF'\n" \
      "```"
    )

    valid = File.read(File.expand_path("../vendor/rod/lib/utils/check-issue/body.txt", __DIR__))
    Rod::Util::CheckIssue.check(valid).should eq("")
  end
end
