# Optimized version of homework task

require 'oj'
require 'minitest/autorun'

def parse_user_and_session(user_data)

  browsers, times, dates = user_data[1..-1].map do |session|
    browser, time, date = *session.split(',')[2..5]
    [browser.upcase, time.to_i, date]
  end.transpose

  [
      [ # собранныя статистика по пользователю
          user_data[0].split(',')[1..2].join(' '),
          {
              'sessionsCount' =>user_data.size - 1,
              'totalTime' => "#{times.sum} min.",
              'longestSession' => "#{times.max} min.",
              'browsers' => browsers.sort.join(', '),
              'usedIE' => browsers.any?{ |b| b.start_with?('INTERNET EXPLORER') },
              'alwaysUsedChrome' => browsers.all?{ |b| b.start_with?('CHROME') },
              'dates' => dates.sort.reverse
          }
      ],
      browsers, #массив браузеров пользователя
  ]
end

def work(source_data_file = 'data.txt', disable_gc = false)
  GC.disable if disable_gc

  grouped_user_data = File.read(source_data_file).split("\nuser,").map{ |ss| ss.split("\nsession,") }

  grouped_user_data[0][0]['user,'] = '' # Перед первым пользователем нет символа новой строки,
  grouped_user_data[-1][-1][-1] ='' # В конце последнего надо убрать перенос строки
  
  parsed_user_data = grouped_user_data.map{ |user_data| parse_user_and_session(user_data ) }

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report['totalUsers'] = parsed_user_data.size

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = parsed_user_data.flat_map { |user_data| user_data[1] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = parsed_user_data.sum{ |user_data| user_data[0][1]['sessionsCount'] }

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям

  report['usersStats'] = parsed_user_data.map(&:first).to_h

  File.write('result.json', Oj.dump(report)+"\n")
end


class TestMe < Minitest::Test
  def setup
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

  def test_result
    work
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
