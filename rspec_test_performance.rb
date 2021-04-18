require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

def prepare_file(size)
  system("head -n #{size} data_large.txt > data_#{size}.txt")
end

def linear_work(size)
  prepare_file(size)
  work("data_#{size}.txt")
end

describe 'Performance' do
  describe 'linear work' do
    let(:size) { 500000 }
    it 'works under 5 s' do
      expect {
        linear_work(size)
      }.to perform_under(5).sec.warmup(2).times.sample(5).times
    end

    let(:sizes) { [500000, 1000000, 1500000] }
    it 'performs linear' do
        expect { |n, _i| linear_work(n) }.to perform_linear.in_range(sizes)
    end
  end
end