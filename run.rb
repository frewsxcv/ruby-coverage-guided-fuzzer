# frozen_string_literal: true

require 'coverage'

fork do
  Coverage.start(:all)
  load('foo.rb')

  fuzz(Random.new.bytes(10))

  p Coverage.result
end

Process.wait
