require_relative '../spec_helper'
require_relative '../../task-1'

RSpec.describe 'Asymptotic' do
  it 'perform slower than linear' do
    # sizes = bench_range(1000, 50_000)
    #
    # files = sizes.map do |n|
    #   prepare_sample_for_speed_test(n)
    #   "data_files/data#{n}.txt"
    # end
    #
    # expect { |n, i|
    #   work(files[i])
    # }.to perform_power.in_range(1000, 50_000)
  end
end