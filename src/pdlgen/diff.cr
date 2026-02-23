require "file"
require "regex"
require "similar"

module Pdlgen
  module Diff
    # CompareFiles returns the diff between files a, b.
    def self.compare_files(a : String, b : String) : Bytes?
      # Read file contents
      old_content = File.read(a)
      new_content = File.read(b)

      # If files are identical, return nil (no diff)
      return if old_content == new_content

      # Create text diff of lines
      diff = Similar::TextDiff.from_lines(old_content, new_content)

      # Generate unified diff with file labels
      unified = diff.unified_diff.header(File.basename(a), File.basename(b))

      # Convert to string and then to bytes
      io = IO::Memory.new
      unified.to_writer(io)
      io.to_s.to_slice
    end

    # FileInfo contains file information.
    struct FileInfo
      property name : String
      property info : File::Info

      def initialize(@name, @info)
      end

      def to_s(io : IO) : Nil
        io << File.basename(@name)
      end
    end

    # FindFilesWithMask walks dir finding all files with the regexp mask, removing
    # any exclude'd files.
    def self.find_files_with_mask(dir : String, mask : String, exclude : Array(String) = [] of String) : Array(FileInfo)
      mask_re = Regex.new(mask)

      # Build list of protocol files on disk
      files = [] of FileInfo
      dir = dir.chomp(File::SEPARATOR) + File::SEPARATOR

      Dir.glob(File.join(dir, "**", "*")) do |path|
        next if path == dir
        info = File.info?(path)
        next if info.nil? || info.directory?

        # Skip if same as current or doesn't match file mask
        fn = path[dir.bytesize..]
        next unless mask_re.match(fn)
        next if exclude.includes?(File.basename(fn))

        # Add to files
        files << FileInfo.new(path, info)
      end

      files
    end

    # WalkAndCompare walks dir, looking for files matching the supplied regexp
    # mask, successively comparing each against filename. The first having a diff
    # (compared by most recent first) will be returned.
    #
    # Useful for comparing multiple files to find the most recent difference from
    # a set of files matching mask that likely have the same content.
    def self.walk_and_compare(dir : String, mask : String, filename : String, cmp : Proc(FileInfo, FileInfo, Bool)) : Bytes?
      files = find_files_with_mask(dir, mask)
      return if files.empty?

      # Sort most recent using comparator (descending)
      files.sort! do |a, b|
        cmp.call(a, b) ? -1 : 1
      end

      # Find filename in files
      i = files.index { |file| File.basename(file.name) == File.basename(filename) }
      return if i.nil?

      # Compare and return first with diff
      while i > 0
        i -= 1
        buf = compare_files(files[i].name, filename)
        if buf && !buf.empty?
          return buf
        end
      end

      nil
    end
  end
end
