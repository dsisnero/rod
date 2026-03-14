require "./spec_helper"

describe "utils exec parity" do
  it "formats cli args and escapes go strings" do
    Rod::Util::Utils.format_cli_args(["ab c", "abc"]).should eq(%("ab c" abc))
    Rod::Util::Utils.escape_go_string("`test`").should eq("`` + \"`\" + `test` + \"`\" + ``")
  end

  it "exec_line captures stdout when std=false" do
    out = Rod::Util::Utils.exec_line(false, "echo hello")
    out.should contain("hello")
  end

  it "exec returns captured output for std=true path like go utils exec" do
    out = Rod::Util::Utils.exec("echo hello")
    out.should contain("hello")
  end

  it "exec_line raises on missing or invalid command" do
    expect_raises(Exception) { Rod::Util::Utils.exec_line(false, "") }
    expect_raises(Exception) { Rod::Util::Utils.exec_line(false, "definitely-not-a-real-command") }
  end
end
