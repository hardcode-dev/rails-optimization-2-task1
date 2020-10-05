# frozen_string_literal: true

require 'tempfile'

RSpec.describe '#work' do
  it 'produces valid result for known input' do
    expected_result = File.read('spec/fixtures/result.json')

    Tempfile.create do |result|
      work(src: 'spec/fixtures/data.txt', dest: result.path)

      actual_result = result.read

      expect(actual_result).to eq(expected_result)
    end
  end
end
