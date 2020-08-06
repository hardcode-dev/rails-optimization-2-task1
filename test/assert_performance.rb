# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1.rb'

RSpec.configure { |config| config.include RSpec::Benchmark::Matchers }

describe 'Performance' do
  describe 'large data' do
    let(:file) { 'data_large.txt' }

    it 'works under 30 sec' do
      expect { work(file) }.to perform_under(30).sec
    end
  end
end
