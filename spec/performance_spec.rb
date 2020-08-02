# frozen_string_literal: true

require_relative '../task-1'

require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'Performance' do
  ROWS_COUNT = 70000
  FILENAME = "data#{ROWS_COUNT}.txt"

  before { `head -n #{ROWS_COUNT} data_large.txt > #{FILENAME}` }
  after { `rm #{FILENAME}` }

  it 'success' do
    expect { work(filename: FILENAME) }.to perform_under(350).ms.warmup(2).times.sample(5).times
  end
end
