# frozen_string_literal: true

require 'coverage'

# Is the `fuzz` function defined in the fuzz target?
def fuzz_function_exists?(file_path)
  reader, writer = IO.pipe
  fork do
    load(file_path)
    begin
      method(:fuzz)
    rescue NameError
      writer.puts('false')
    else
      writer.puts('true')
    end
  end
  Process.wait
  writer.close
  reader.gets == "true\n"
end

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
