# Deoptimized version of homework task

require 'json'
require 'pry'
# require 'date'
# require 'minitest/autorun'

def parse_user(user)
  fields = user.split(',')
  "#{fields[1]} #{fields[2]}"
end

def _user_with_session_lines(data)
  data.map { |line| line.split(',') }
end

def _user_with_session(data)
  data.split("\n")
end

def _times(data)
  data.map { |s| s[4].to_i }
end

def _user_browsers(data)
  data.map { |s| s[3] }
end

def _browsers(data)
  data.map { |line| line.split(',')[3] }
end

def _session_lines(data)
  data.split('session')
end

def work(filename = 'data_large.txt', disable_gc: false)
  start_time = Time.now

  # puts 'Start work'
  GC.disable if disable_gc

  file = File.read(filename)

  split_by_users = file.split('user,')
  split_by_users.delete_at(0)

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

  report['totalUsers'] = split_by_users.size

  session_lines = _session_lines(file)
  session_lines.delete_at(0)

  browsers = _browsers(session_lines)
  browsers_uniq = browsers.uniq

  report['uniqueBrowsersCount'] = browsers_uniq.size
  report['totalSessions'] = session_lines.size
  report['allBrowsers'] = browsers_uniq.sort.join(',').upcase

  # Статистика по пользователям
  user_stats = {}

  split_by_users.each do |user_with_session|
    user_stat = {}
    user_with_session_lines = _user_with_session(user_with_session)
    user = parse_user(user_with_session_lines.delete_at(0))

    user_sessions = _user_with_session_lines(user_with_session_lines)
    user_stat['sessionsCount'] = user_sessions.size

    times = _times(user_sessions)
    user_stat['totalTime'] = "#{times.sum} min."
    user_stat['longestSession'] = "#{times.max} min."

    user_browsers = _user_browsers(user_sessions)
    user_browsers_uniq = user_browsers.uniq
    user_stat['browsers'] = user_browsers.sort.join(', ').upcase
    user_stat['usedIE'] = !!user_browsers_uniq.find { |b| b =~ /Internet Explorer/ }
    user_stat['alwaysUsedChrome'] = user_browsers_uniq.all? { |b| b.upcase =~ /Chrome/ }

    user_stat['dates'] = user_sessions.map { |s| s[5] }.sort.reverse!
    user_stats[user] = user_stat
  end

  report['usersStats'] = user_stats

  File.write('result.json', "#{report.to_json}\n")
  puts Time.now - start_time
end

work

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

#   def test_result
#     work
#     expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
#     assert_equal expected_result, File.read('result.json')
#   end
# end
