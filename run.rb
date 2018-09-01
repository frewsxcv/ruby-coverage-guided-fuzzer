# frozen_string_literal: true

require 'coverage'

if ARGV.length != 1
  puts 'USAGE: fuzz.rb <FILE TO FUZZ>'
  exit
end
file_path = ARGV[0].freeze

# TODO: ensure we don't load this file

fork do
  Coverage.start(:all)
  load(file_path)

  fuzz(Random.new.bytes(10))

  p Coverage.result
end

Process.wait
