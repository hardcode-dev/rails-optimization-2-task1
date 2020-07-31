require 'rspec-benchmark'
require_relative 'task-1-improved'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'works under 0.8s' do
    expect {
      ReportGenerator.new.work(input: 'data_160000.txt', output: 'test_output/result_test.json', disable_gc: true)
    }.to perform_under(800).ms.warmup(2).times.sample(5).times
  end

  it 'performs linear' do
    sizes = [10_000, 20_000, 40_000]

    expect { |_n, i|
      ReportGenerator.new.work(input: "data_#{sizes[i]}.txt", output: "test_output/result_test_#{sizes[i]}.json", disable_gc: true)
    }.to perform_linear.in_range(sizes)
  end
end