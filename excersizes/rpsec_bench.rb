require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

def linear_work(size)
    a = []
    size.times { a << nil}
end


def quadratic_work(size)
    a = []
    (size*size).times { a << nil}
end

describe 'Performance' do 
    describe 'linear work' do
        let(:size) { 10000 }
        it 'works under 1 ms' do
            expect{
                linear_work(size)
            }.to perform_under(1).ms.warmup(2).times.sample(10).times
        end

        let(:measurement_time_seconds) { 1 }
        let(:warmup_seconds) { 0.2 }

        it 'works faster than 1000 ips' do
            expect {
                linear_work(size)
            }.to perform_at_least(1000).within(measurement_time_seconds).warmup(warmup_seconds).ips
        end

        it 'perform linear' do
            expect { |n, i| linear_work(n) }.to perform_linear.in_range(10,10_000)
        end

    end

    describe 'quadratic work' do
        let(:size) { 10 }
        it 'works under 1 ms' do
            expect{
                quadratic_work(size)
            }.to perform_under(1).ms.warmup(2).times.sample(10).times
        end
        
        it 'performs power' do
            expect { |n, i| quadratic_work(n) }.to perform_power.in_range(10, 10_000)
        end

        it 'performs slower than linear' do
            expect { quadratic_work(size)}.to perform_slower_than { linear_work(size)}
        end
    end    
end