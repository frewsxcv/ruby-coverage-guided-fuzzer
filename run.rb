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
      message = Marshal.load(Base64.strict_decode64(reader.gets.strip))

      encoded_bytes = message[:bytes]
      cov_hash = message[:cov_hash]

      if seen.include?(cov_hash)
        next
      end

      # TODO: merge all the cov hashes we've seen to print coverage %
      #       https://github.com/mame/coverage-helpers

      seen[cov_hash] = encoded_bytes
      puts('Encountered new code path with input bytes:')
      puts("\tbytes: #{encoded_bytes.inspect}")
    end
  end
end

def start_fuzzing_process(file_path, writer)
  fork do
    STDOUT.reopen('/dev/null')
    STDIN.reopen('/dev/null')
    loop do
      # TODO: better input generation
      bytes = Random.new.bytes(10)

      fork do
        # Ideally, we’d also include branch coverage here via:
        #
        #   Coverage.start(:all)
        #
        # ...but if we turn this on, it seems each fuzz target run we d
        # generates a new unique hash, even if it goes the same code path. So
        # some further investigation is needed before enabling this.
        Coverage.start

        begin
          load(file_path)
          fuzz(bytes)
        rescue => e
          # TODO: this error doesn't show up
          puts "Encountered an exception: #{e}"
          exit(1)
        end

        writer.puts(
          Base64.strict_encode64(
            Marshal.dump({
              bytes: bytes,
              cov_hash: Coverage.result.hash,
            })
          )
        )
      end
      Process.wait
    end
  end
end

def run
  if ARGV.length != 1
    STDERR.puts('USAGE: fuzz.rb <FILE TO FUZZ>')
    exit(1)
  end
  file_path = ARGV[0].freeze

  # TODO: ensure we don't load this file
  if !fuzz_function_exists?(file_path)
    STDERR.puts("ERROR: `fuzz` function doesn’t exist in #{file_path}")
    exit(1)
  end

  reader, writer = IO.pipe

  reporting_pid = start_reporting_process(reader)
  start_fuzzing_process(file_path, writer)

  Process.wait(reporting_pid)
end

run
