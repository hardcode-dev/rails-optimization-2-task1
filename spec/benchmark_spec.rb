# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Report' do
  describe '#call' do
    it 'works on 100_000 items under 1 sec' do
      expect { Report.new.call('data100000.txt') }.to perform_under(1).sec
    end
  end
end
