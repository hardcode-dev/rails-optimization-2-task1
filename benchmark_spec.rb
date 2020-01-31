require "rspec"
require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe "BenchmarkSpec" do
  RSpec::Benchmark.configure do |config|
    config.run_in_subprocess = false
    config.disable_gc = false
  end
  it do
    expect { work("data50.txt") }.to perform_under(1).sec.warmup(2).times.sample(10).times
  end

  it do
    expect { work("data_large.txt") }.to perform_under(30).sec.warmup(2).times.sample(2).times
  end
end
