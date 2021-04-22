require "minitest/autorun"
require "minitest/benchmark"

require_relative 'work.rb'

class SortBenchmark < Minitest::Benchmark
  EXPECTED_EXECUTION_TIME = {
    1000 => 0.0075,
    10_000 => 0.075,
    100_000 => 0.75
  }.freeze

  def self.bench_range
    EXPECTED_EXECUTION_TIME.keys
  end

  def setup
    File.write('result.json', '')
  end

  def warmup
    perform EXPECTED_EXECUTION_TIME.keys.last
  end

  def bench_execution_time
    warmup

    validation = proc do |range, times|
      [range, times].transpose.each do |count, time|
        assert_operator time, :<, EXPECTED_EXECUTION_TIME[count],
                        "Execution for #{count} time(s) too slow (#{time}s)"
      end
    end

    assert_performance(validation) do |n|
      perform n
    end
  end

  def bench_linearity
    warmup

    3.times do
      assert_performance_linear(0.995) do |n|
        perform n
      end
    end
  end

  private

  def perform(limit)
    work(file_name: 'data_large.txt', progress_bar: false, limit: limit)
  end
end