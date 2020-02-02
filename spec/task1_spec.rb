

require 'rspec-benchmark'
require_relative '../task-1.rb'

RSpec.describe "Performance testing" do
  include RSpec::Benchmark::Matchers


  it do
    expect {
      Work.new('data_large.txt').work
    }.to perform_under(30_000).ms

  end
end