# frozen_string_literal: true

require 'tempfile'

RSpec.describe '#work', :benchmark do
  context 'for large data' do
    let(:source) { 'samples/data_large.txt' }

    it 'performs under 30 seconds' do
      Tempfile.create do |result|
        expect { work(src: source, dest: result.path) }
          .to perform_under(30).secs
      end
    end
  end
end
