require "./util/cache"
require "./util/semver"
require "xml"
require "json"
require "http/client"
require "base64"
require "file"
require "time"

module Pdlgen
  module Util
    # Base URLs for protocol definitions
    CHROMIUM_BASE = "https://chromium.googlesource.com/chromium/src"
    CHROMIUM_DEPS = "#{CHROMIUM_BASE}/+/%s/DEPS"
    CHROMIUM_URL  = "#{CHROMIUM_BASE}/+/%s/third_party/blink/public/devtools_protocol/browser_protocol.pdl"

    V8_BASE = "https://chromium.googlesource.com/v8/v8"
    V8_URL  = "#{V8_BASE}/+/%s/include/js_protocol.pdl"

    # v8 <= 7.6.303.13 uses this path. left for posterity.
    V8_URL_OLD = "#{V8_BASE}/+/%s/src/inspector/js_protocol.pdl"

    # chromium < 80.0.3978.0 uses this path. left for posterity.
    CHROMIUM_URL_OLD = "#{CHROMIUM_BASE}/+/%s/third_party/blink/renderer/core/inspector/browser_protocol.pdl"

    # Logf is a shared logging function.
    def self.logf(format : String, *args)
      puts sprintf(format, *args)
    end

    # Regular expression for matching version numbers.
    VER_RE = /^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$/

    # Get retrieves a file from disk or from the remote URL, optionally base64
    # decoding it and writing it to disk.
    def self.get(cache : Cache) : Bytes
      # Ensure directory exists
      dir = File.dirname(cache.path)
      Dir.mkdir_p(dir)

      # Check if exists on disk and not expired
      if File.exists?(cache.path) && cache.ttl != Time::Span::ZERO
        mod_time = File.info(cache.path).modification_time
        if Time.utc < mod_time + cache.ttl
          return File.read(cache.path).to_slice
        end
      end

      # Try to fetch with HTTP caching
      buf = fetch_with_cache(cache)

      buf
    end

    # Fetch with HTTP caching support (ETag, Last-Modified, retry on 429)
    private def self.fetch_with_cache(cache : Cache) : Bytes
      etag_path = cache.path + ".etag"
      headers = HTTP::Headers.new

      # Add caching headers if we have cached version
      if File.exists?(cache.path)
        # If-Modified-Since
        mod_time = File.info(cache.path).modification_time
        headers["If-Modified-Since"] = mod_time.to_rfc2822

        # If-None-Match (ETag)
        if File.exists?(etag_path)
          etag = File.read(etag_path).strip
          headers["If-None-Match"] = etag unless etag.empty?
        end
      end

      uri = URI.parse(cache.url)
      max_retries = 3
      retry_delay = 2.0 # seconds

      max_retries.times do |attempt|
        logf("RETRIEVING: %s%s", cache.url, attempt > 0 ? " (attempt #{attempt + 1}/#{max_retries})" : "")

        client = HTTP::Client.new(uri)
        response = client.get(cache.url, headers: headers)

        case response.status_code
        when 200 # OK
          # Store ETag if provided
          if etag = response.headers["ETag"]?
            File.write(etag_path, etag)
          end

          buf = response.body.to_slice

          # decode if needed
          if cache.decode
            str = String.new(buf)
            buf = Base64.decode(str)
          end

          logf("WRITING: %s", cache.path)
          File.write(cache.path, buf)

          return buf
        when 304 # Not Modified
          # Update modification time to refresh TTL
          File.touch(cache.path)
          return File.read(cache.path).to_slice
        when 429 # Too Many Requests
          # Rate limited, wait and retry
          if attempt < max_retries - 1
            sleep_time = retry_delay * (2 ** attempt) # exponential backoff
            logf("Rate limited (429), waiting %.1f seconds...", sleep_time)
            sleep(sleep_time)
            next
          else
            raise "HTTP request failed: 429 Too Many Requests (after #{max_retries} attempts)"
          end
        else
          raise "HTTP request failed: #{response.status_code} #{response.status_message}"
        end
      end

      raise "Failed to retrieve #{cache.url} after #{max_retries} attempts"
    end

    # Ref wraps a ref.
    struct Ref
      getter value : String
      getter target : String

      def initialize(@value, @target)
      end
    end

    # GetLatestVersion determines the latest tag version listed on the gitiles
    # html page.
    def self.get_latest_version(cache : Cache) : String
      buf = get(cache)

      # Parse HTML using XML (gitiles outputs XHTML)
      doc = XML.parse_html(String.new(buf))

      # Find h3 containing "Tags" then adjacent ul li
      # XPath: //h3[contains(text(), 'Tags')]/following-sibling::ul[1]/li
      xpath_result = doc.xpath("//h3[contains(text(), 'Tags')]/following-sibling::ul[1]/li")
      vers = [] of Semver
      case xpath_result
      when XML::NodeSet
        xpath_result.each do |li|
          text = li.text.strip
          if VER_RE =~ text
            vers << make_semver(text)
          end
        end
      else
        raise "expected NodeSet from XPath, got #{xpath_result.class}"
      end
      if vers.empty?
        raise "could not find a valid tag at #{cache.url}"
      end
      vers.sort!
      latest = vers.last
      # Replace last - with . (reverse of make_semver)
      v = latest.to_s
      if v.count('-') >= 1
        n = v.rindex('-')
        if n
          v = v[0...n] + "." + v[n + 1..]
        end
      end
      v
    end

    # GetRefs returns the refs for the url.
    def self.get_refs(cache : Cache) : Hash(String, Ref)
      buf = get(cache)

      # chop first line (gitiles JSON output has a first line like )]}'
      str = String.new(buf)
      if idx = str.index('\n')
        str = str[idx + 1..]
      end

      # parse JSON
      hash = Hash(String, JSON::Any).from_json(str)
      refs = Hash(String, Ref).new
      hash.each do |k, v|
        refs[k] = Ref.new(v["value"].as_s, v["target"].as_s)
      end
      refs
    end

    REV_RE = /(?is)\s+'([0-9a-f]+)'/

    # GetDepVersion version retrieves the v8 version used for the browser version.
    def self.get_dep_version(typ : String, ver : String, deps : Cache, refs : Cache) : String
      buf = get(deps)

      # determine revision
      mark = "'#{typ}_revision':"
      i = buf.index(mark)
      if i.nil?
        raise "could not find revision for #{typ} version #{ver}"
      end
      buf = buf[i + mark.bytesize..]
      m = REV_RE.match(String.new(buf))
      if m.nil?
        raise "no revision for #{typ} version #{ver}"
      end
      rev = m[1]

      # grab refs
      r = get_refs(refs)

      # find tag
      r.each do |k, v|
        next unless k.starts_with?("refs/tags/")
        if v.value == rev
          return k.lchop("refs/tags/")
        end
      end

      raise "could not find #{typ} revision tag for rev #{rev}"
    end
  end
end
