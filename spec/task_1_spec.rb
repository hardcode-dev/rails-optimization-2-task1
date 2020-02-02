require_relative 'spec_helper'
require 'pry'
require_relative '../lib/task-1'

def linear_work(size)
  a = []
  size.times { a << nil }
end

describe 'work' do
  before { FileUtils.rm_f('result.json') }
  subject { Optimization::TaskOne.work('tests/fixtures/data.txt', false) }

  describe 'regression' do
    before do
      subject
    end

    it 'the result should eq fixture' do
      expected_result = File.read('tests/fixtures/result.json')
      expect(expected_result).to eq File.read('result.json')
    end
  end

  describe 'performance' do
    it 'works under 0.07 ms' do
      expect do
        linear_work(subject)
      end.to perform_under(0.07).ms.warmup(2).times.sample(10).times
    end
  end
end
