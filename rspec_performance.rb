# frozen_string_literal: true

require 'rspec-benchmark'
require_relative 'task-1'
require 'minitest/autorun'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
  ENV['TEST_ENV'] = 'test'
end

describe 'Process test' do
  it 'works under 2.4 seconds for 400 records' do
    expect { work('rspec_test_data.txt') }.to perform_under(2).ms.warmup(2).times.sample(10).times
  end
end
