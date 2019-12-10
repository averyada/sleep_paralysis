#!/usr/bin/env ruby

require 'rest_client'
require 'open-uri'
require 'fileutils'
require 'json'
require 'pp'

API_KEY = JSON.parse(File.read("#{__dir__}/token.json"))['API_KEY']

images = Dir.entries("#{__dir__}/input_images").select {|f| !File.directory? f }

images.map! {|i| File.absolute_path("input_images/#{i}") }
puts images

output = Dir.open("#{__dir__}/output_images/")

images.each do |image|
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

  path = File.join __dir__, 'output_images', File.basename(image)
  FileUtils.touch(path)

  File.open(path) do |f|
  end
  open(json_r['output_url']) do |result|
    File.open(path, 'w') do |f|
      f.write(result.read)
    end
  end
end

puts "Done!"
