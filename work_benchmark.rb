require 'benchmark'
require 'benchmark/ips'
require_relative 'task-1'

# GC.disable
$stdout = File.new('reports/benchmarks.txt', 'w')
$stdout.sync = true

Benchmark.ips do |x|
  # x.time = 1
  # x.warmup = 2
  x.stats = :bootstrap
  x.confidence = 95

  x.report('Work 1x') { work(file_path: 'data_samples/data.txt') }
  x.report('Work 2x') { work(file_path: 'data_samples/data2x.txt') }
  x.report('Work 4x') { work(file_path: 'data_samples/data4x.txt') }
  x.report('Work 8x') { work(file_path: 'data_samples/data8x.txt') }

  x.compare!
end

time = Benchmark.realtime do
  work
end
puts "finish in #{time.round(5)}"
