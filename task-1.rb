require 'minitest/autorun'
require 'oj'

UserStruct = Struct.new(:id,
                        :first_name,
                        :last_name,
                        :age,
                        :sessions_count,
                        :total_time,
                        :longest_session,
                        :browsers,
                        :dates)

def parse_user(fields)
  UserStruct.new(
      fields[1].to_i,
      fields[2],
      fields[3],
      fields[4],
      0,
      0,
      0,
      [],
      [])
end


def include_ie?(browsers)
  browsers.each {|b| return true if b =~ /INTERNET EXPLORER/}
  return false
end

def all_chrome?(browsers)
  browsers.each {|b| return false unless b =~ /CHROME/}
  return true
end

def work(filename = 'data_large.txt', disable_gc: false)
  puts 'Start work'
  GC.disable if disable_gc

  lines_count = File.read(ENV['DATA_FILE'] || filename).size
  file_lines = Array.new(lines_count)
  file_lines = File.read(ENV['DATA_FILE'] || filename).split("\n")

  users = []
  sessions = []
  unique_browsers = {}

  report = {
      totalUsers: 0,
      uniqueBrowsersCount: 0,
      totalSessions: 0,
      allBrowsers: nil,
      usersStats: {}
  }

  file_lines.each do |line|
    fields = line.split(',')
    if fields[0] == 'user'
      id = fields[1].to_i
      users[id] = parse_user(fields)
      report[:usersStats]["#{fields[2]} #{fields[3]}"] ||= {
          sessionsCount: 0,
          totalTime: 0,
          longestSession: 0,
          browsers: [],
          usedIE: false,
          alwaysUsedChrome: false,
          dates: []
      }

      report[:totalUsers] += 1
    else
      user = users[fields[1].to_i]
      user.sessions_count += 1
      session_time = fields[4].to_i
      user.total_time += session_time
      user.longest_session = session_time if user.longest_session < session_time
      user.browsers << fields[3].upcase!
      user.dates << fields[5]
      report[:totalSessions] += 1
      unique_browsers[fields[3]] = nil
    end
  end
  #
  users.each do |user|
    user_key = "#{user.first_name} #{user.last_name}"
    # report['usersStats'][user_key] ||= {}
    report[:usersStats][user_key][:sessionsCount] = user.sessions_count
    # Собираем количество времени по пользователям
    report[:usersStats][user_key][:totalTime] = user.total_time.to_s + ' min.'
    # Выбираем самую длинную сессию пользователя
    report[:usersStats][user_key][:longestSession] = user.longest_session.to_s + ' min.'
    # Браузеры пользователя через запятую
    report[:usersStats][user_key][:browsers] = user.browsers.sort.join(', ')
    # Хоть раз использовал IE?
    report[:usersStats][user_key][:usedIE] = include_ie?(user.browsers)
    # Всегда использовал только Chrome?
    report[:usersStats][user_key][:alwaysUsedChrome] = all_chrome?(user.browsers)
    # Даты сессий через запятую в обратном порядке в формате iso8601
    report[:usersStats][user_key][:dates] = user.dates.sort!.reverse!
  end

  report[:uniqueBrowsersCount] = unique_browsers.keys.size
  report[:allBrowsers] = unique_browsers.keys.sort!.join(',')
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


  File.open("result.json","w") do |f|
    f.write Oj.dump(report, mode: :compat)
    f.write "\n"
  end
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt~',
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
    work 'data.txt.~'
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
