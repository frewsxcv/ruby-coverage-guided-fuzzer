# ruby-coverage-guided-fuzzer

PoC fuzzer written in Ruby for Ruby powered by Ruby’s built-in coverage library.

```
$ ruby run.rb examples/foo.rb
Encountered new code path with input bytes:
	bytes: "(\"\r\e\xB5A\xA3\xA4\xE6g"
Encountered new code path with input bytes:
	bytes: "1'\x9F\xA2\x18t\xD7\xC2WH"
Encountered new code path with input bytes:
	bytes: "0\xF4\xDA\x8D\xD83\xD8\xDE\xDD\x9F"
```

All files licensed [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
