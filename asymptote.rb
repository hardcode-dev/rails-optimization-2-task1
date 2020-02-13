require 'rspec-benchmark'
require 'pry'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

def setup_files range
  system('mkdir -p test')
  range.each do |n|
    system("head -n #{n} data_large.txt > test/data_#{n}.txt")
  end
end

def delete_files
  system('rm test/*')
  system('rmdir test')
end

def linear_work(size)
  work("test/data_#{size}.txt")
end

describe 'Performance' do
  # let(:large_range) { [5000, 10000, 20000, 40000, 80000] }
  let(:large_range) { [500, 1000, 2000, 4000, 8000, 16000] }
  let(:small_range) { [50, 100, 200, 400, 800, 1600] }
  after(:all) do
    delete_files
  end
  describe 'work on large sets' do
    it 'performs linear' do
      setup_files large_range
      expect { |n, _i| linear_work(n) }.to perform_linear.in_range(large_range).ratio(2).sample(10).times
    end
  end
  describe 'work on small sets' do
    it 'performs logarithmic' do
      setup_files small_range
      expect { |n, _i| linear_work(n) }.to perform_logarithmic.in_range(small_range).ratio(2).sample(30).times
    end
  end
end

