require "coverage"
Coverage.start(:all)
# Coverage.start(branches: true)
# Coverage.start(methods: true)
# Coverage.start(lines: true)
load("foo.rb", true)
p Coverage.result
