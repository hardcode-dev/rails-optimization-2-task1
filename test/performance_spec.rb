# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'task-1' do
    it 'works under N ms' do
      expect { work('tmp/data_80000.txt') }.to perform_under(500).ms.warmup(2).times.sample(3).times
    end
  end
end
