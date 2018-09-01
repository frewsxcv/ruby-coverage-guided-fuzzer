# frozen_string_literal: true

require 'coverage'
require 'base64'

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

def start_reporting_process(reader)
  fork do
    seen = {}
    loop do
      encoded_bytes, cov_hash = reader.gets.strip.split('_')

      if seen.include?(cov_hash)
        next
      end

      seen[cov_hash] = Base64.strict_decode64(encoded_bytes)
      puts(seen)
    end
  end
end

def start_fuzzing_process(file_path, writer)
  fork do
    # STDOUT.reopen('/dev/null')
    STDIN.reopen('/dev/null')
    loop do
      bytes = Random.new.bytes(10)

      fork do
        Coverage.start(:all)

        begin
          load(file_path)
          fuzz(bytes)
        rescue => e
          puts "Encountered an exception: #{e}"
          exit(1)
        end

        writer.puts(Base64.strict_encode64(bytes) + '_' + Coverage.result.hash.to_s)
      end
      Process.wait
    end
  end
end

def run
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

  reporting_pid = start_reporting_process(reader)
  start_fuzzing_process(file_path, writer)

  Process.wait(reporting_pid)
end

run
