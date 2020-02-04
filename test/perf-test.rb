require_relative '../task-1'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'task-1' do
  it 'performs under 150ms for small file' do
    expect {
      work('test/support/small_samples/data_2500.txt', disable_gc: false)
    }.to perform_under(110).ms.warmup(1).times.sample(5).times
  end

  it 'performs under 31 sec for large file' do
    expect {
      work('data_large.txt')
    }.to perform_under(31000).ms.warmup(1).times.sample(2).times
  end
end
