# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  context 'with 20k string perform under 60 ms' do
    it { expect { work('files/data-20k') }.to perform_under(60).ms.warmup(2).times.sample(10).times }
  end

  context 'with 100k string perform under 480 ms' do
    it { expect { work('files/data-100k') }.to perform_under(480).ms.warmup(2).times.sample(10).times }
  end

  context 'with 300k string(~10%) perform under 1.8 sec' do
    it { expect { work('files/data-300k') }.to perform_under(1.8).sec.warmup(2).times.sample(10).times }
  end

  context 'with 1M string(~30%) perform under 7.5 sec' do
    it { expect { work('files/data-1m') }.to perform_under(7.5).sec.warmup(2).times.sample(10).times }
  end

  context 'with ~3M string(100%) perform under 30 sec' do
    it { expect { work('files/data_large') }.to perform_under(30).sec.warmup(2).times.sample(10).times }
  end
end
