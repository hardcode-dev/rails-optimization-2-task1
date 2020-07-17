require 'rspec'
require 'rspec-benchmark'

require_relative '../task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe '#work' do
  describe 'проверка логики' do
    let(:filename) { 'spec/fixtures/data.txt' }
    let(:expected_result) do
      '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    end

    it 'вернет корректные данные' do
      work(filename)
      expect(File.read('result.json')).to eq expected_result
    end
  end

  describe 'проверка скорости' do
    context 'когда 10к записей' do
      let(:filename) { 'data/data10000.txt' }

      it 'скорость обработки данных не больше 110 мс' do
        expect do
          work(filename)
        end.to perform_under(110).ms.warmup(2).times.sample(10).times
      end
    end

    context 'когда все записи' do
      let(:filename) { 'data/data_large.txt' }

      it 'скорость обработки данных не больше 45 секунд' do
        expect do
          work(filename)
        end.to perform_under(45).sec.warmup(2).times.sample(3).times
      end
    end
  end
end
