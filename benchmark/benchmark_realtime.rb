# frozen_string_literal: true

require 'benchmark'
require_relative '../task-1'

def realtime(name = '', &block)
  time = Benchmark.realtime do
    block.call
  end

  puts "#{name} Finish in #{time.round(2)}"
end

[10_000, 20_000, 40_000, 80_000, 160_000].each do |size|
  realtime(size) { work("tmp/data_#{size}.txt") }
end
