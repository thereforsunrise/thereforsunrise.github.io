#!/usr/bin/env ruby

require "front_matter_parser"
require "tempfile"
require "tilt"
require "yaml"

LINK_REGEXP = /\[\[\s*(\S+)\s*\]\]/
MARKDOWN_TEMPLATE = """---
title: %s
---

# %s"""

def generate_required_markdown_files_from_magic_links_in_markdown_file(markdown_file)
  markdown_file_contents = File.read(markdown_file)

  markdown_file_contents.to_enum(:scan, LINK_REGEXP).map { Regexp.last_match }.each do |markdown_file_link|
    markdown_title = markdown_file_link[1]
    markdown_file_to_create = "#{markdown_title}.md"

    unless File.exist? markdown_file_to_create
      File.open(markdown_file_to_create, 'w') do |f|
        f.write(MARKDOWN_TEMPLATE % [markdown_title, markdown_title])
      end
    end
  end
end

def generate_html_file_from_markdown(markdown_file)
  markdown_file_contents = File.read(markdown_file).gsub(LINK_REGEXP, '[\1](\1.html)')

  html_file = markdown_file.gsub(".md", ".html" )

  parsed = FrontMatterParser::Parser.new(:md).call(markdown_file_contents)

  layout = Tilt['erb'].new("layout.html.erb")
  data = Tilt['markdown'].new { parsed.content }
  html_file_contents = layout.render(self, parsed.front_matter) { data.render }

  File.open(html_file, "w") do |f|
    f.write(html_file_contents)
  end
end

def generate_log
  log_file_slices = Dir.glob("log/*.md").select { |file| file =~ /^log\/\d{4}-\d{2}-\d{2}\.md$/ }.sort.reverse.each_slice(3)

  log_file_slices.each_with_index do |slice, index|
    is_first_iteration = index == 0
    is_last_iteration = (index == log_file_slices.to_a.length - 1)

    log_file = "log/#{index}.md"

    File.open(log_file, "w") do |f|
      f.write <<EOF
---
title: Log
---

# There for Sunrise

## Log
EOF

      slice.each do |l|
        f.write(File.read(l))
        f.write("\n")
      end

      unless is_last_iteration
        f.write <<EOF
[Previous](/log/#{index+1}.html)
EOF
      end

      unless is_first_iteration
        f.write <<EOF
[Next](/log/#{index-1}.html)
EOF
      end
    end

    generate_html_file_from_markdown log_file
  end
end

def markdown_files
  Dir.glob("*.md").reject { |x| x[/(README.md|log)/] }
end

def html_files
  Dir.glob("*.html")
end

puts "Generating site..."

markdown_files.each do |markdown_file|
  generate_required_markdown_files_from_magic_links_in_markdown_file markdown_file
end

markdown_files.each do |markdown_file|
  generate_html_file_from_markdown markdown_file
end

generate_log

html_files.each do |html_file|

end
