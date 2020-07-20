require 'rspec-benchmark'
require_relative '../report'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'generate' do
    it 'works under 35 ms for 1000 records' do
      expect {
        Report.new.generate('test/data_medium.txt', false)
      }.to perform_under(35).ms.warmup(2).times.sample(10).times
    end

    it 'works under 47 sec for 500000 records' do
      expect {
        Report.new.generate('data_large.txt', false)
      }.to perform_under(47).sec.warmup(2).times.sample(3).times
    end
  end
end
