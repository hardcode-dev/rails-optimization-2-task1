require_relative 'task-1'
require 'benchmark'

require 'benchmark/ips'

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 95)

  x.report("ips") do
    work('samples/16000.txt')
  end
end
