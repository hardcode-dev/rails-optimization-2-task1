# frozen_string_literal: true

require 'benchmark'
require_relative 'task-1.rb'

%i(5000 10000 25000 50000 100000 large).each do |size|
  time = Benchmark.realtime do
    work("data_#{size}.txt")
  end
  puts "#{size} rows finished in #{time.round(2)}"
end
