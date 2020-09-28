# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def work
  GC.disable
  file_lines = File.read('data.txt').split("\n")
  # file_lines = File.read('data_large.txt').split("\n")

  users = []
  sessions = {}
  browsers_all = []

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << {
          'id' => cols[1],
          'first_name' => cols[2],
          'last_name' => cols[3],
          'age' => cols[4],
      }
    end
    sessions[cols[1]]  ||= {}
    if cols[0] == 'session'
      sessions[cols[1]]['browsers'] ||= []
      sessions[cols[1]]['times'] ||= []
      sessions[cols[1]]['dates'] ||= []

      browser_current = cols[3].upcase
      sessions[cols[1]]['browsers'] << browser_current
      sessions[cols[1]]['times'] << cols[4].to_i
      sessions[cols[1]]['dates'] << cols[5]
      browsers_all << browser_current
    end
  end

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

  report[:totalUsers] = users.count

  report['uniqueBrowsersCount'] = browsers_all.uniq.count
  # Подсчёт количества уникальных браузеров
  report['totalSessions'] = browsers_all.count
  report['allBrowsers'] = browsers_all.uniq.sort.join(',')

  report['usersStats'] = {}

  # Статистика по пользователям
  users.each do |user|
    report['usersStats'][user['first_name']+ ' ' + user['last_name']] = {}
    report['usersStats'][user['first_name']+ ' ' + user['last_name']]['sessionsCount'] = sessions[user['id']]['times'].count
    report['usersStats'][user['first_name']+ ' ' + user['last_name']]['totalTime'] = sessions[user['id']]['times'].sum.to_s + ' min.'
    report['usersStats'][user['first_name']+ ' ' + user['last_name']]['longestSession'] = sessions[user['id']]['times'].max.to_s + ' min.'
    report['usersStats'][user['first_name']+ ' ' + user['last_name']]['browsers'] = sessions[user['id']]['browsers'].sort.join(', ')
      report['usersStats'][user['first_name']+ ' ' + user['last_name']]['usedIE'] = sessions[user['id']]['browsers'].any? { |b| b =~ /INTERNET EXPLORER/ }
    report['usersStats'][user['first_name']+ ' ' + user['last_name']]['alwaysUsedChrome'] = sessions[user['id']]['browsers'].all? { |b| b =~ /CHROME/ }
    report['usersStats'][user['first_name']+ ' ' + user['last_name']]['dates'] = sessions[user['id']]['dates'].sort.reverse
  end

  File.write('result.json', "#{report.to_json}\n")

  puts 'Finish work'
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
