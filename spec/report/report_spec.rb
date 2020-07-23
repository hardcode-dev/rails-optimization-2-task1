require_relative '../spec_helper'
require_relative '../../task-1'

RSpec.describe 'Report' do
  it 'performs valid report data' do
    work('data_files/regress_data.txt')
    expect(File.read('data_files/regress_expected_data.json')).to eq(File.read('data_files/result.json'))
  end

  it 'works under 60 ms' do
    prepare_sample_for_speed_test(10_000)

    expect {
      work('data_files/data10000.txt')
    }.to perform_under(46).ms.warmup(2).times.sample(10).times
  end

  # it 'big data works under 30 000 ms' do
  #   expect {
  #     work('data_files/data_large.txt')
  #   }.to perform_under(30_000).ms
  # end
end
