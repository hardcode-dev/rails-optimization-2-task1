require 'rspec-benchmark'

require_relative 'optimized'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
  end

describe 'optimized' do
  let(:file_name) { 'tests/data/data_10000.txt' }
  it do
    expect {
      ParserOptimized.work(file_name)
    }.to perform_under(60).ms.warmup(3).times.sample(10).times
  end
end
