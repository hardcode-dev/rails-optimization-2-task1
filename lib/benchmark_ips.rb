# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../task-1'

test_path_100k = 'files/data-100k'
test_path_300k = 'files/data-300k'
test_path_1m = 'files/data-1m'
test_path_data_large = 'files/data_large'

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95
  )

  x.report('100k') { work(test_path_100k) }
  x.report('300k') { work(test_path_300k) }
  x.report('1m') { work(test_path_1m) }
  x.report('data_large') { work(test_path_data_large) }
end
