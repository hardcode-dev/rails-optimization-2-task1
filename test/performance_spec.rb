require 'rspec-benchmark'
require_relative '../lib/worker'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'linear work' do
    let(:file_path) { "#{__dir__}/../data/data2.txt" }

    it '40000 rows works under 210ms' do
      expect {
        worker = Worker.new(file_path)
        worker.run
      }.to perform_under(0.21).sec.warmup(2).times.sample(10).times
    end

    # its bad (
    # it 'has linear asymptotics' do
    #   expect do |n, _i|
    #     worker = Worker.new("#{__dir__}/../data/data#{n}.txt")
    #     worker.run
    #   end.to perform_linear.in_range([1, 2, 3, 4]).sample(10).times
    # end
  end
end
