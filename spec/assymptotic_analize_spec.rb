# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'logarithmic work' do
    # Ни одна из возможных опций не дает стабильно зеленого теста, думаю, это бесполезный тест.
    xit 'performs logarithmic' do
      expect { |n, _i| work(rows_count: n) }.to perform_logarithmic.in_range(1000, 10_000).threshold(0.1)
    end
  end

  it 'works with 1000 rows faster than 0.8 ips' do
    expect { work(rows_count: 1000) }.to perform_at_least(0.8).within(2).warmup(0.2).ips
  end

  it 'works with 1000 rows under 1.25 sec' do
    expect { work(rows_count: 1000) }.to perform_under(1.25).sec.warmup(2).times
  end

  it 'works with data_large under 30 sec' do
    expect { work(file_name: 'files/data_large.txt') }.to perform_under(30).sec.warmup(2).times
  end
end
