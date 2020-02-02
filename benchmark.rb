
require_relative 'task-1'
require 'benchmark/ips'

ENV['FILENAME'] = 'data_small.txt'




GC.disable
Benchmark.ips do |x|
  # Configure the number of seconds used during
  # the warmup phase (default 2) and calculation phase (default 5)
  x.config(:time => 5, :warmup => 2)

  x.stats = :bootstrap
  x.confidence = 95

  x.report 'main' do
    Work.new.work
  end



end

