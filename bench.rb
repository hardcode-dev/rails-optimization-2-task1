require 'benchmark'
require_relative 'task-1.rb'

time = Benchmark.realtime do
  work('data_large.txt', disable_gc: false)
end

puts "Finish in #{time.round(2)}"
