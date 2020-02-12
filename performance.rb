require_relative 'task-1.rb'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'file handler' do
    it 'works under 30s' do
      expect {
        work('data_large.txt', disable_gc: false)
      }.to perform_under(30000).ms.warmup(2).times.sample(10).times
    end
  end
end
