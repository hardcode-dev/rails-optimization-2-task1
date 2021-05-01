require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
    config.include RSpec::Benchmark::Matchers
end

ProgressBarEnabler.disable!
describe 'Perfomance' do
    let(:size) { 250000 }
    it 'works under 2s' do
        expect{
            work("data/data#{size}.txt")
        }.to perform_under(2).sec.sample(10).times
    end

    it 'perform linear' do
        expect { |n, _i| work("data/data#{n}.txt") }.to perform_linear.in_range([10000, 20000, 30000, 40000, 50000, 60000])
    end
end
