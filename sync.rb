#!/usr/bin/env ruby

require 'fileutils'

script_dir = File.dirname(__FILE__)

source_dir = ARGV[0]
dest_dir = File.join(script_dir, "log")

Dir.glob(File.join(source_dir, '**/*.txt')).each do |file_path|
  dest_file = file_path.split(File::SEPARATOR)[-3..-1].join("-").gsub(".txt", ".md")
  dest_path = File.join(dest_dir, dest_file)

  FileUtils.cp(file_path, dest_path)
end

