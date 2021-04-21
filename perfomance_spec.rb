require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'works under 160 ms' do
    expect {
      work('data25000.txt', 'result.json')
    }.to perform_under(160).ms.warmup(2).times.sample(10).times
  end
end
