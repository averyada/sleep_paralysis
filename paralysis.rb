#!/usr/bin/env ruby

require 'rest_client'
require 'open-uri'
require 'fileutils'
require 'json'
require 'pp'

API_KEY = JSON.parse(File.read("#{__dir__}/token.json"))['API_KEY']

puts "Running sleep paralysis..."

@input_folder = ARGV[0]
@output_folder = ARGV[1]

if ARGV.length != 2
  puts "Requires 2 arguments, please supply an input and output folder (no globbing)."
  puts "Example: ruby paralysis.rb input output"
  exit 1
end

if ARGV.length == 2
  begin
    Dir.mkdir(@input_folder) unless File.exists?(@input_folder)
    Dir.mkdir(@output_folder) unless File.exists?(@output_folder)
  rescue SystemCallError
    puts "Platform-dependent error when trying to create new I/O directories."
  end
end

@input_dir = Dir.open(@input_folder)

@input_dir.each_child do |f|
  image = File.absolute_path(f, @input_folder)

  r = RestClient::Request.execute(
      method: :post, 
      url: 'https://api.deepai.org/api/deepdream',
      timeout: 600,
      headers: {'api-key' => API_KEY},
      payload: {
          'image' => File.new(image),
      }
  )

  puts r.body

  if r.code == 200
    json_r = JSON.parse(r.body)
  end

  output_path = File.join __dir__, @output_folder, File.basename(image)
  FileUtils.touch(output_path)

  open(json_r['output_url']) do |result|
    File.open(output_path, 'w') do |f|
      f.write(result.read)
    end
  end
end


puts "Done!"
