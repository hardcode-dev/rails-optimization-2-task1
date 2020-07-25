require 'benchmark'
require_relative '../lib/worker'

Benchmark.bmbm do |x|
  x.report('20000-rows:') do
    worker = Worker.new("#{__dir__}/../data/data1.txt")
    worker.run
  end

  x.report('40000-rows:') do
    worker = Worker.new("#{__dir__}/../data/data2.txt")
    worker.run
  end

  x.report('80000-rows:') do
    worker = Worker.new("#{__dir__}/../data/data3.txt")
    worker.run
  end

  x.report('120000-rows:') do
    worker = Worker.new("#{__dir__}/../data/data4.txt")
    worker.run
  end
end
