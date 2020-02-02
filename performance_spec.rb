require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  let(:file_name_1) { 'data10000.txt' }
  let(:file_name_2) { 'data10000.txt' }
  let(:file_name_3) { 'data20000.txt' }
  let(:file_names) do
    {
      5_000 => file_name_1,
      10_000 => file_name_2,
      20_000 => file_name_3
    }
  end

  it 'Обработка выполняется не более 70 мс' do
    expect do
      work(file_name_2, disable_gc: false)
    end.to perform_under(70).ms.warmup(2).times.sample(2).times
  end

  it 'Увеличение времени обработки' do
    expect do |rows, _i|
      work(file_names[rows])
    end.to perform_power.in_range(5_000, 20_000)
  end
end
