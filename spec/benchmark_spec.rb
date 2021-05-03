require_relative 'spec_helper'
require_relative '../task-1'

describe 'perfomance' do
  let(:data) { 'data100000.txt' }
  let(:budget) { 1 }

  context 'when perfomance ok' do
    it do
      expect { work(file: data, disable_gc: true) }.to perform_under(budget).sec.warmup(1).times.sample(10).times
    end
  end
end
