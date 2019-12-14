#!/usr/bin/env ruby

require 'rest_client'
require 'open-uri'
require 'fileutils'
require 'json'
require 'pp'

API_KEY = JSON.parse(File.read("#{__dir__}/token.json"))['API_KEY']

puts "Running sleep paralysis..."

@input_folder = nil
@output_folder = nil

if ARGV.length != 2
  puts "Requires 2 arguments, please supply an input and output folder (no globbing)."
  exit 1
end

if ARGV.length == 2
  if !Dir.exist? ARGV[0] or !Dir.exist? ARGV[1]
    puts "The first two arguments must be directories."
    exit 1
  else
    @input_folder = ARGV[0]
    @output_folder = ARGV[1]
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

  File.open(output_path) do |f|
  end
  open(json_r['output_url']) do |result|
    File.open(output_path, 'w') do |f|
      f.write(result.read)
    end
  end
end


puts "Done!"
