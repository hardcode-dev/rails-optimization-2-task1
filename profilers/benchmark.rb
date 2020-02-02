# gem install kalibera
require 'benchmark/ips'
# require_relative '../task-1-initial.rb'

Benchmark.ips do |x|
  require_relative '../task-1-initial.rb'
  x.report('initial') { work('data_10_000.txt', disable_gc: true) }

  require_relative '../task-1-optim.rb'
  x.report('optim') { work_optim('data_10_000.txt', disable_gc: true) }

  x.compare!
end
