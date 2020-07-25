require 'benchmark'
require_relative '../lib/worker'

Benchmark.bmbm do |x|
  x.report('real:') do
    worker = Worker.new("#{__dir__}/../tmp/data_large.txt")
    worker.run
  end
end
