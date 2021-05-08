require 'rspec-benchmark'
require_relative 'report'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'program' do
    let(:data) { 'data_16000.txt' }
    it 'works under 100 ms' do
      expect {
        work(data)
      }.to perform_under(100).ms.warmup(2).times.sample(10).times
    end
  end
end
