require 'benchmark'
require_relative 'task-1-improved'

time = Benchmark.realtime do
  ReportGenerator.new.work(input: 'data_160000.txt', output: 'result_benchmark.json');
end

puts "Finish in #{time.round(2)}"