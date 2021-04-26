# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'set'
require 'ruby-progressbar'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  progressbar = ProgressBar.create(total:  users_objects.size)
  progressbar.title = 'Process collect stats from users:'

  users_objects.each.with_index do |user, i|
    progressbar.progress = (i + 1)
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(yield user)
  end
end

def work(file_name)
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []
  
  progressbar = ProgressBar.create(total: file_lines.size)
  progressbar.title = 'Process file parsing:'

  file_lines.each.with_index do |line, i|
    progressbar.progress = (i + 1)

    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
    else
      sessions << parse_session(cols)
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
  uniqueBrowsers = Set.new
  sessions.each do |session|
    browser = session['browser']
    uniqueBrowsers << browser unless uniqueBrowsers.include? browser
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []
  sessions_grouped_by_users = sessions.group_by { |s| s['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = sessions_grouped_by_users[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects << user_object
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    time = user.sessions.map {|s| s['time'].to_i}
    browsers = user.sessions.map {|s| s['browser'].upcase}

    {}.tap do |h|
      # Собираем количество сессий по пользователям
      h['sessionsCount'] = user.sessions.count
      # Собираем количество времени по пользователям
      h['totalTime'] = time.sum.to_s + ' min.'
      # Выбираем самую длинную сессию пользователя
      h['longestSession'] = time.max.to_s + ' min.'
      # Браузеры пользователя через запятую
      h['browsers'] = browsers.sort.join(', ')
      # Хоть раз использовал IE?
      h['usedIE'] = browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
      # Всегда использовал только Chrome?
      h['alwaysUsedChrome'] = !(browsers.any? { |b| b !=~ /CHROME/ })
      h['dates'] = user.sessions.map{|s| s['date']}.sort.reverse
    end
  end

  File.write('result.json', "#{report.to_json}\n")
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
    work('data.txt')
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
