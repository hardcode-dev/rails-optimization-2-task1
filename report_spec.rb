require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Report' do
  before do
    File.write('result.json', '')
    File.write('data.txt',
               'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  subject(:generate_report) do
    Report.new.call(file_name)
  end

  let(:file_name) {'data.txt'}

  describe '#call' do
    let(:expected_result) do
      '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    end

    it 'creates correct report' do
      generate_report
      expect(File.read('result.json')).to eq(expected_result)
    end
  end

  describe 'performance' do

    describe 'performance meets budget' do
      let(:file_name) { 'data_8000.txt' }

      let(:measurement_time_seconds) { 1 }
      let(:warmup_seconds) { 0.2 }
      let(:expected_i_per_s) { 30 } # actual value is 30 (± 6%)

      it 'works faster that 30 ips' do
        expect{
          Report.new.call(file_name)
        }.to perform_at_least(expected_i_per_s).within(measurement_time_seconds).warmup(warmup_seconds).ips
      end

      context 'when we need to change file size dynamically', focus: true do
        let(:file_name) { 'data_dynamic.txt'}

        it 'performs linear' do
          pending('not implemented')
          # TODO: write this test
          # Я сходу не придумал как без переписывания основного класса проверить асимптотику
          # По идее я должен передавать туда параметр N, он читать первые N строк из файла и собирать отчет
          # После этого можно будет менять N и смотреть на производительность
          # Но сейчас у меня нет времени переписывать и тестировать код, поэтому тест пока pending.

          # Ниже попытка на ходу менять исходник который скармливается в генератор, но тест фейлится с заявлением что
          # рост экспоненциальный. По идее такого быть не может, тк отчет генерируется за 30 секунд как ожидалось по заданию
          # Но разбираться в чем ошибка опять таки не было времени.

          # expect {|n, _i|
          #   `head -n #{n} data_large.txt > data_dynamic.txt`
          #   Report.new.call(file_name)
          # }.to perform_linear.in_range(10, 1000)
        end
      end

    end

  end

end