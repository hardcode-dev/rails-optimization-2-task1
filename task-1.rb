# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

# class User
#   attr_reader :attributes, :sessions
#
#   def initialize(attributes:, sessions:)
#     @attributes = attributes
#     @sessions = sessions
#   end
# end

def parse_user(user)
  fields = user.split(',')
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def work
  file_lines = File.read('data_large.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(line)
    when 'session'
      sessions << parse_session(line)
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
  # Подсчёт количества уникальных браузеров
  unique_browsers = sessions.map { |session| session['browser'] }.uniq
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] =
    sessions
    .map { |s| s['browser'].upcase }
    .sort
    .uniq
    .join(',')

  # Статистика по пользователям
  grouped_sessions = sessions.group_by { |session| session['user_id'] }

  report['usersStats'] = {}
  # # Собираем количество сессий по пользователям
  # # Собираем количество времени по пользователям
  # # Выбираем самую длинную сессию пользователя
  # # Браузеры пользователя через запятую
  # # Хоть раз использовал IE?
  # # Всегда использовал только Chrome?
  # # Даты сессий через запятую в обратном порядке в формате iso8601
  users.each do |user|
    sessions = grouped_sessions[user['id']]
    all_user_times = sessions.map { |s| s['time'].to_i }
    all_user_browsers = sessions.map { |s| s['browser'].upcase }
    all_user_dates = sessions.map { |s| s['date'] }
    user_key = "#{user['first_name']} #{user['last_name']}"
    report['usersStats'][user_key] ||= {}
    user_data = {
      'sessionsCount' => sessions.count,
      'totalTime' => all_user_times.sum.to_s + ' min.',
      'longestSession' => all_user_times.max.to_s + ' min.',
      'browsers' => all_user_browsers.sort.join(', '),
      'usedIE' => all_user_browsers.join.include?('INTERNET EXPLORER'),
      'alwaysUsedChrome' => (all_user_browsers.sort.last =~ /CHROME/) || false,
      'dates' => all_user_dates.sort.reverse
    }
    report['usersStats'][user_key] = user_data
  end

  File.write('result.json', "#{report.to_json}\n")
end

# class TestMe < Minitest::Test
#   def setup
#     File.write('result.json', '')
#     File.write('data.txt',
# 'user,0,Leida,Cira,0
# session,0,0,Safari 29,87,2016-10-23
# session,0,1,Firefox 12,118,2017-02-27
# session,0,2,Internet Explorer 28,31,2017-03-28
# session,0,3,Internet Explorer 28,109,2016-09-15
# session,0,4,Safari 39,104,2017-09-27
# session,0,5,Internet Explorer 35,6,2016-09-01
# user,1,Palmer,Katrina,65
# session,1,0,Safari 17,12,2016-10-21
# session,1,1,Firefox 32,3,2016-12-20
# session,1,2,Chrome 6,59,2016-11-11
# session,1,3,Internet Explorer 10,28,2017-04-29
# session,1,4,Chrome 13,116,2016-12-28
# user,2,Gregory,Santos,86
# session,2,0,Chrome 35,6,2018-09-21
# session,2,1,Safari 49,85,2017-05-22
# session,2,2,Firefox 47,17,2018-02-02
# session,2,3,Chrome 20,84,2016-11-25
# ')
#   end
#
#   def test_result
#     work
#     expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
#     assert_equal expected_result, File.read('result.json')
#   end
# end
