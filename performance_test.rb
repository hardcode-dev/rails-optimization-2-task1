require 'rspec-benchmark'
require 'rspec/autorun'
require_relative 'main'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'works near 2 sec' do
    expect { work('data300000.txt') }.to perform_under(2.1).sec.warmup(2).times.sample(10).times
  end
end
