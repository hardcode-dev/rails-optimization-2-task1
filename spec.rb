require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

# GC.disable

describe 'Performance' do
  it 'works under 30 s' do
    expect {
      work(file_name = 'data_large.txt')
    }.to perform_under(30).sec.warmup(2).times.sample(5).times
  end

  it 'twice large works under 30 s' do
    expect {
      work(file_name = 'data_twice_large.txt')
    }.to perform_under(30).sec.warmup(2).times.sample(5).times
  end

  it 'works with 10_000 lines under 50 ms' do
    expect {
      work(file_name = 'data_10000_lines.txt')
    }.to perform_under(50).ms.warmup(2).times.sample(10).times
  end
end

# GC.enable
# GC.start
