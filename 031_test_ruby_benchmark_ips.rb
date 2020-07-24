require_relative 'task-1'
require 'benchmark/ips'

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 20)

  x.report('do working') do
    work
  end
end
