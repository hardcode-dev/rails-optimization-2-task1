require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work(file_name: 'tmp/data_1000000.txt')
  work(file_name: 'tmp/data_large.txt', disable_gc: true)
end

puts "Finish in #{time.round(2)}"
