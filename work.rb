require_relative 'task-1'

# work(ENV.fetch('DATA_FILE', 'data.txt'))

require 'benchmark'
time = Benchmark.realtime do
  work('tmp/data_large.txt')
end

puts "data_large Finish in #{time.round(2)}"
