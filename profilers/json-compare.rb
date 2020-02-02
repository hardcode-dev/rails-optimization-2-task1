require 'benchmark/ips'
require 'json'

# GC.disable

h = (1..1_000).map { |i| ["a#{i}", i] }.to_h

Benchmark.ips do |x|
  x.report("dump") { JSON.dump(h) }
  x.report("to_json") { h.to_json }
  x.report('generate') { JSON.generate(h) }
  x.report('fast_generate') { JSON.fast_generate(h) }

  x.compare!
end
