require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'Lenear work' do
    it 'works with 10000 strings under 30 ms' do
      expect { Work.new.work('data10000.txt') }.to perform_under(30).ms
    end
  end
end
