require "option_parser"
require "file"
require "path"
require "json"

require "./pdl"
require "./util"
require "./fixup"
require "./gen"
# require "./gen/crystal"
require "./diff"

module Pdlgen
  class CLI
    # Command line flags
    @debug = false
    @ttl = 24.hours
    @chromium = ""
    @v8 = ""
    @latest = false
    @pdl = ""
    @cache = ""
    @out = ""
    @no_clean = false
    @no_dump = false
    @base_pkg = "Cdp"
    @crystal_wl = "LICENSE,README.md,*.pdl,shard.yml,shard.lock"

    def initialize
    end

    def self.run
      CLI.new.run
    end

    def run
      Util.logf("starting pdlgen")
      parse_options

      # Set cache path
      if @cache.empty?
        cache_dir = "temp"
        Dir.mkdir_p(cache_dir) unless Dir.exists?(cache_dir)
        @cache = File.join(cache_dir, "cdproto-gen")
      end

      # Get latest versions if needed (only when not using local PDL)
      get_versions if @pdl.empty?

      # Load protocol definitions
      proto_defs = load_proto_defs

      # Write combined protocol definitions and show diff with previous version
      if @pdl.empty?
        combined_dir = File.join(@cache, "pdl", "combined")
        Dir.mkdir_p(combined_dir) unless Dir.exists?(combined_dir)
        proto_file = File.join(combined_dir, "#{@chromium}_#{@v8}.pdl")

        Util.logf("WRITING: %s", proto_file)
        File.write(proto_file, proto_defs.bytes)

        # display differences between generated definitions and previous version on disk
        diff_buf = Diff.walk_and_compare(combined_dir, "^([0-9_.]+)\\.pdl$", proto_file, ->(a : Diff::FileInfo, b : Diff::FileInfo) do
          n = File.basename(a.name, ".pdl").split('_')
          m = File.basename(b.name, ".pdl").split('_')
          if n[0] == m[0]
            Util.compare_semver(n[1], m[1])
          else
            Util.compare_semver(n[0], m[0])
          end
        end)
        if diff_buf && !diff_buf.empty?
          STDOUT.write(diff_buf)
        end
      end

      # Process domains
      process_domains(proto_defs)
    rescue ex
      STDERR.puts "error: #{ex.message}"
      STDERR.puts ex.backtrace.join("\n") if @debug
      exit 1
    end

    private def parse_options
      OptionParser.parse do |parser|
        parser.banner = "Usage: pdlgen [options]"

        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end

        parser.on("-v", "--version", "Show version") do
          puts "pdlgen #{Pdlgen::VERSION}"
          exit
        end

        parser.on("--debug", "Toggle debug (writes generated files to disk without post-processing)") do
          @debug = true
        end

        parser.on("--ttl=DURATION", "File retrieval caching TTL (default: 24h)") do |ttl|
          # Parse duration like "24h", "1d", etc.
          @ttl = parse_duration(ttl)
        end

        parser.on("--chromium=VERSION", "Chromium protocol version") do |v|
          @chromium = v
        end

        parser.on("--v8=VERSION", "V8 protocol version") do |v|
          @v8 = v
        end

        parser.on("--latest", "Use latest protocol") do
          @latest = true
        end

        parser.on("--pdl=FILE", "Path to PDL file to use") do |file|
          @pdl = file
        end

        parser.on("--cache=DIR", "Protocol cache directory") do |dir|
          @cache = dir
        end

        parser.on("--out=DIR", "Package output directory") do |out_dir|
          @out = out_dir
        end

        parser.on("--no-clean", "Toggle not cleaning (removing) existing directories") do
          @no_clean = true
        end

        parser.on("--no-dump", "Toggle not dumping generated protocol file to out directory") do
          @no_dump = true
        end

        parser.on("--base-pkg=PACKAGE", "Base package name (default: Cdp)") do |pkg|
          @base_pkg = pkg
        end

        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
      end
    end

    private def parse_duration(str : String) : Time::Span
      # Simple parsing for now: assume hours
      if str.ends_with?("h")
        str[0...-1].to_i.hours
      elsif str.ends_with?("d")
        str[0...-1].to_i.days
      else
        str.to_i.hours
      end
    rescue
      24.hours
    end

    private def get_versions
      # Get latest Chromium version if not specified
      if @chromium.empty?
        Util.logf("GETTING: latest chromium version")
        cache = Util::Cache.new(
          url: Util::CHROMIUM_BASE,
          path: File.join(@cache, "html", "chromium.html"),
          ttl: @ttl
        )
        @chromium = Util.get_latest_version(cache)
        Util.logf("CHROMIUM: %s", @chromium)
      end

      # Get V8 version
      if @v8.empty?
        if @latest
          Util.logf("GETTING: latest v8 version")
          cache = Util::Cache.new(
            url: Util::V8_BASE,
            path: File.join(@cache, "html", "v8.html"),
            ttl: @ttl
          )
          @v8 = Util.get_latest_version(cache)
        else
          Util.logf("GETTING: v8 version for chromium %s", @chromium)
          deps_cache = Util::Cache.new(
            url: (Util::CHROMIUM_DEPS % @chromium) + "?format=TEXT",
            path: File.join(@cache, "deps", "chromium", @chromium),
            ttl: @ttl,
            decode: true
          )
          refs_cache = Util::Cache.new(
            url: Util::V8_BASE + "/+refs?format=JSON",
            path: File.join(@cache, "refs", "v8.json"),
            ttl: @ttl
          )
          @v8 = Util.get_dep_version("v8", @chromium, deps_cache, refs_cache)
        end
        Util.logf("V8: %s", @v8)
      end
    end

    private def load_proto_defs : Pdl::PDL
      if !@pdl.empty?
        Util.logf("PROTOCOL: %s", @pdl)
        buf = File.read(@pdl).to_slice
        return Pdl.parse(buf)
      end

      proto_defs = [] of Pdl::PDL

      # Load Chromium protocol
      load = ->(url : String, typ : String, ver : String) do
        full_url = (url + "?format=TEXT") % ver
        cache = Util::Cache.new(
          url: full_url,
          path: File.join(@cache, "pdl", typ, ver + ".pdl"),
          ttl: @ttl,
          decode: true
        )
        buf = Util.get(cache)

        # Resolve includes
        resolved_buf = resolve_includes(buf, full_url, typ, ver, @cache)

        # Parse
        proto_def = Pdl.parse(resolved_buf)
        proto_defs << proto_def
      end

      # Grab browser + js definition
      load.call(Util::CHROMIUM_URL, "chromium", @chromium)
      load.call(Util::V8_URL, "v8", @v8)

      # Add HAR definition
      har = Pdl.parse(Pdl::HAR.to_slice)
      proto_defs << har

      Pdl.combine(proto_defs)
    end

    private def process_domains(proto_defs : Pdl::PDL)
      domains = proto_defs.domains

      # Sort domains
      domains.sort_by!(&.domain)

      processed = [] of Pdl::Domain
      pkgs = [] of String

      domains.each do |domain|
        # Skip deprecated domains unless they have always_emit items
        if domain.deprecated? && !has_always_emit(domain)
          Util.logf("SKIPPING(domain): %s [deprecated]", domain.domain)
          next
        end

        # Temporary fix for Page.setDownloadBehavior
        if domain.domain == "Page"
          domain.commands.each do |command|
            if command.name == "setDownloadBehavior"
              command.always_emit = true
            end
          end
        end

        # Will process
        pkgs << Gen::CrystalUtil.package_name(domain)
        processed << domain

        # Cleanup types, events, commands
        domain.types = cleanup_types("type", domain.domain, domain.types)
        domain.events = cleanup_types("event", domain.domain, domain.events)
        domain.commands = cleanup_types("command", domain.domain, domain.commands)
      end

      # Apply fixup
      Fixup.fix_domains(processed)

      # Get generator
      generator = Gen.generators["crystal"]
      if generator.nil?
        raise "no generator"
      end

      # Emit
      emitter = generator.call(processed, @base_pkg)
      files = emitter.emit

      # Clean output directory if needed
      if !@no_clean && !@out.empty?
        clean_output(files)
      end

      # Write files
      Util.logf("WRITING: %d files", files.size)
      write_files(files)

      Util.logf("done.")
    end

    private def has_always_emit(d : Pdl::Domain) : Bool
      d.types.any?(&.always_emit?) ||
        d.events.any?(&.always_emit?) ||
        d.commands.any?(&.always_emit?)
    end

    private def cleanup_types(n : String, dtyp : String, typs : Array(Pdl::Type)) : Array(Pdl::Type)
      result = [] of Pdl::Type

      typs.each do |type|
        typ = dtyp + "." + type.name
        if false && type.deprecated? && !type.always_emit?
          Util.logf("SKIPPING(%s): %s [deprecated]", n.ljust(7), typ)
          next
        end

        if type.redirect && !type.always_emit?
          Util.logf("SKIPPING(%s): %s [redirect:%s]", n.ljust(7), typ, type.redirect)
          next
        end

        if type.properties && !type.properties.empty?
          type.properties = cleanup_types(n[0] + " property", typ, type.properties)
        end

        if type.parameters && !type.parameters.empty?
          type.parameters = cleanup_types(n[0] + " param", typ, type.parameters)
        end

        if type.returns && !type.returns.empty?
          type.returns = cleanup_types(n[0] + " return", typ, type.returns)
        end

        result << type
      end

      result
    end

    private def clean_output(files : Hash(String, String))
      Util.logf("CLEANING: %s", @out)

      outpath = File.join(@out, "")
      whitelist = @crystal_wl.split(',')

      Dir.glob(File.join(@out, "**", "*")).each do |path|
        next unless File.exists?(path)
        next if path == outpath

        # Skip if file or path starts with ., is whitelisted, or is one of
        # the files whose output will be overwritten
        pn = path[outpath.bytesize..] rescue ""
        fn = File.basename(path)

        if pn.empty? || pn.starts_with?('.') || fn.starts_with?('.') || whitelisted?(fn, whitelist) || files.has_key?(pn)
          next
        end

        Util.logf("REMOVING: %s", path)
        File.delete(path) if File.file?(path)
        Dir.delete(path) if Dir.exists?(path) && Dir.empty?(path)
      end
    end

    private def whitelisted?(filename : String, whitelist : Array(String)) : Bool
      whitelist.any? do |pattern|
        if pattern.includes?('*')
          # Simple glob matching
          if pattern == "*.pdl"
            filename.ends_with?(".pdl")
          else
            pattern == filename
          end
        else
          pattern == filename
        end
      end
    end

    private def resolve_includes(buf : Bytes, url : String, typ : String, ver : String, cache_dir : String) : Bytes
      lines = String.new(buf).lines
      base_url = url[0...url.rindex('/')]? || url
      result = [] of String
      lines.each do |line|
        if match = line.match(Pdl::INCLUDE_RE)
          include_path = match[1]
          include_url = "#{base_url}/#{include_path}?format=TEXT"
          cache_path = File.join(cache_dir, "pdl", typ, "domains", include_path)
          Util.logf("INCLUDE: %s", include_path)
          cache = Util::Cache.new(
            url: include_url,
            path: cache_path,
            ttl: @ttl,
            decode: true
          )
          included_buf = Util.get(cache)
          # recursively resolve includes in the included file
          resolved = resolve_includes(included_buf, include_url, typ, ver, cache_dir)
          result << String.new(resolved)
        else
          result << line
        end
      end
      result.join("\n").to_slice
    end

    private def write_files(files : Hash(String, String))
      files.each do |path, content|
        full_path = @out.empty? ? path : File.join(@out, path)
        dir = File.dirname(full_path)
        Dir.mkdir_p(dir) unless Dir.exists?(dir)

        File.write(full_path, content)
        Util.logf("  %s", full_path)
      end
    end
  end
end

if PROGRAM_NAME == __FILE__
  Pdlgen::CLI.run
end
