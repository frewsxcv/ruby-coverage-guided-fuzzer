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
      writer.putc('0')
    else
      writer.putc('1')
    end
  end
  reader.getc == '1'
end

if ARGV.length != 1
  puts 'USAGE: fuzz.rb <FILE TO FUZZ>'
  exit(1)
end
file_path = ARGV[0].freeze

# TODO: ensure we don't load this file
if !fuzz_function_exists?(file_path)
  puts "ERROR: `fuzz` function doesn’t exist in #{file_path}"
  exit(1)
end

reader, writer = IO.pipe

fork do
  loop do
    puts "reading from IO pipe: #{reader.gets.strip}"
  end
end

loop do
  fork do
    STDOUT.reopen('/dev/null')
    STDIN.reopen('/dev/null')

    Coverage.start(:all)

    begin
      load(file_path)
      fuzz(Random.new.bytes(10))
    rescue => e
      puts "Encountered an exception: #{e}"
      exit(1)
    end

    writer.puts(Coverage.result.hash)
  end
  Process.wait
end
