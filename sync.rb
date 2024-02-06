#!/usr/bin/env ruby

require 'fileutils'

SCRIPT_DIR = File.expand_path(File.dirname(__FILE__)) 

source_dir = ARGV[0]
dest_dir = File.join(SCRIPT_DIR, "log")

Dir.glob(File.join(source_dir, '**/*.txt')).each do |file_path|
  next if file_path[/conflicted/]

  dest_file = file_path.split(File::SEPARATOR)[-3..-1].join("-").gsub(".txt", ".md")
  dest_path = File.join(dest_dir, dest_file)

  FileUtils.cp(file_path, dest_path)
end

