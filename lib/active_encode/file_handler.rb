# frozen_string_literal: true
module ActiveEncode
  module FileHandler
    def build_file_list(directory, filename)
      file_path = File.join(directory, "**", filename)
      # Some of the files generated by the ffmpeg encode seem to be hidden files.
      # This uses File::FNM_DOTMATCH to include them in the results.
      Dir.glob(file_path, File::FNM_DOTMATCH)
    end

    def file_check(path, older_than)
      File.mtime(path) < DateTime.now - older_than && File.file?(path)
    end

    def remove_files(files, older_than)
      files_to_delete = files.select { |f| file_check(f, older_than) }
      FileUtils.rm(files_to_delete) unless files_to_delete.empty?
    end

    def remove_empty_directories(directories)
      directories_to_delete = directories.select { |d| Dir.empty?(d) }
      non_empty_directories = directories - directories_to_delete
      directories_to_delete += non_empty_directories.select { |ned| Dir.children(ned) == ["outputs"] && directories_to_delete.include?(File.join(ned, "outputs")) }
      FileUtils.rmdir(directories_to_delete) unless directories_to_delete.empty?
    end

    def remove_child_files(directories, older_than)
      files_to_delete = []
      directories.each do |d|
        files = Dir.children(d).select { |ch| ActiveEncode.file_check(File.join(d, ch), older_than) }
        files_to_delete += files.collect { |f| File.join(d, f) }
      end
      FileUtils.rm(files_to_delete) unless files_to_delete.empty?
    end
  end
end
