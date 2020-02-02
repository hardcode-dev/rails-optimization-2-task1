# frozen_string_literal: true

require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  Report.new.call('data_small.txt')
end

puts "Finish in #{time.round(2)}"
