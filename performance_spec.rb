# frozen_string_literal: true

require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'execution time' do
    before { GC.disable }
    after { GC.enable }

    it 'performs large file in less than 30 seconds' do
      expect do
        work('files/data_large.txt')
      end.to perform_under(30).sec
    end
  end
end
