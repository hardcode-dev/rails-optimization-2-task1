# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe '.work' do
    it 'works under 30 ms' do
      expect { work(file_name: 'tmp/data_large.txt') }.to perform_under(30).sec.warmup(1).times.sample(1).times
    end
  end
end
