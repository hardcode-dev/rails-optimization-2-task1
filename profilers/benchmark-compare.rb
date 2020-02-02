require 'benchmark/ips'
require_relative '../task-1.rb'

gc = { disable_gc: true }

Benchmark.ips do |x|
  # x.config(:stats => :bootstrap, :confidence => 99)

  x.report('100') { work('data_100.txt', gc) }

  x.report('1_000') { work('data_1_000.txt', gc) }

  x.report("10_000") { work('data_10_000.txt', gc) }

  x.compare!
end
