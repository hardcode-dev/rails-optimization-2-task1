require 'minitest/autorun'
require 'pry'
require_relative '../lib/task-1'

describe 'work' do
  before { FileUtils.rm_f('result.json') }

  describe 'regression' do
    before do
      Optimization::TaskOne.work('tests/fixtures/data.txt', false)
    end

    it 'the result should eq fixture' do
      expected_result = File.read('tests/fixtures/result.json')
      assert_equal expected_result, File.read('result.json')
    end
  end
end
