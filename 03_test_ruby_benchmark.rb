require_relative 'task-1'
require 'benchmark'
require 'benchmark/ips'

puts 'Start'

# GC.disable

time =Benchmark.realtime do
  work
end

puts "FINISH in #{time.round(2)}"
