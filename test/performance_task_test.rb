require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    it 'works under 6 ms for 100 records' do
      expect {
        work('test/data_medium.txt')
      }.to perform_under(6).ms.warmup(2).times.sample(20).times
    end
  end
end
