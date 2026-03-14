require "http/client"
require "json"

module Rod::Util::CheckIssue
  private VERSION_PATTERN  = /Rod Version: v[0-9.]+/
  private GO_BLOCK_PATTERN = /(?ms)```go\r?\n(.+?)```/

  def self.check(body : String) : String
    messages = [] of String

    checks = [
      ->check_version(String),
      ->check_markdown(String),
      ->check_go_code(String),
    ]

    checks.each do |check_fn|
      if msg = check_fn.call(body)
        messages << msg
      end
    end

    messages.join("\n\n")
  end

  private def self.check_version(body : String) : String?
    match = VERSION_PATTERN.match(body)
    matched = match.try(&.[0])
    if matched.nil? || matched == "Rod Version: v0.0.0"
      return "Please add a valid `Rod Version: v0.0.0` to your issue. Current version is #{current_ver}"
    end

    nil
  end

  private def self.current_ver : String
    token = ENV["GITHUB_TOKEN"]?
    return "<nil>" if token.nil? || token.empty?

    begin
      headers = HTTP::Headers{
        "Authorization" => "token #{token}",
        "User-Agent"    => "rod-check-issue",
      }
      response = HTTP::Client.get("https://api.github.com/repos/go-rod/rod/tags?per_page=1", headers: headers)
      data = JSON.parse(response.body)
      data.as_a.first?.try(&.as_h["name"]?.try(&.as_s)) || "<nil>"
    rescue
      "<nil>"
    end
  end

  private def self.check_markdown(body : String) : String?
    issues = [] of String
    in_fence = false

    body.each_line(chomp: false).with_index(1) do |line, line_no|
      stripped = line.rstrip

      if stripped.starts_with?("```")
        if in_fence
          in_fence = false
        else
          lang = stripped[3..]? || ""
          if lang.empty?
            issues << %(#{line_no} MD040/fenced-code-language Fenced code blocks should have a language specified [Context: "```"])
          end
          in_fence = true
        end
      end

      content = line.gsub(/\r?\n\z/, "")
      trailing = content.match(/ +\z/).try(&.[0].size) || 0
      if trailing == 1
        actual = trailing
        issues << "#{line_no}:24 MD009/no-trailing-spaces Trailing spaces [Expected: 0 or 2; Actual: #{actual}]"
      end
    end

    return nil if issues.empty?
    "Please fix the format of your markdown:\n\n```txt\n#{issues.join("\n")}\n```"
  end

  private def self.check_go_code(body : String) : String?
    errors = [] of String
    block_index = 0

    body.scan(GO_BLOCK_PATTERN) do |match|
      code = match[1]
      formatted = format_code(code)
      open_count = formatted.count('{')
      close_count = formatted.count('}')
      next if open_count <= close_count

      block_index += 1
      lines = formatted.lines
      last = lines.last? || ""
      col = last.rstrip.size + 1
      row = lines.size

      errors << "@@ golang markdown block #{block_index} @@"
      errors << "#{row}:#{col}: expected ';', found 'EOF'"
      errors << "#{row}:#{col}: expected '}', found 'EOF'"
    end

    return nil if errors.empty?
    "Please fix the golang code in your markdown:\n\n```txt\n#{errors.join("\n")}\n```"
  end

  private def self.format_code(code : String) : String
    source = code.strip
    if source.starts_with?("package ")
      source
    elsif source.includes?("func ")
      "package main\n#{vars(source)}#{source}"
    else
      "package main\n#{vars(source)}func main() {\n#{source}\n}"
    end
  end

  private def self.vars(code : String) : String
    vars = String.build do |io|
      if code.includes?("page.") && !code.includes?("page :=")
        io << "var page *rod.Page\n"
      end
      if code.includes?("browser.") && !code.includes?("browser :=")
        io << "var browser *rod.Browser\n"
      end
    end
    vars
  end
end
