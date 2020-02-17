
require 'benchmark'
require_relative 'work_method.rb'

time = Benchmark.realtime do
  work('data_large.txt', disable_gc: false)
end

puts "Finish in #{time.round(2)}"
