# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

DEMO_DATA_PATH = "#{__dir__}/demo_data/data_large.txt"

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

GC.disable

describe 'benchmark' do
  it 'check time for 100_000 lines' do
    expect { work(DEMO_DATA_PATH) }.to perform_under(30).ms.sample(5) # 100_000 lines < 0.92 sec
  end
end
