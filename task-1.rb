# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'oj'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def session_times(user)
  user.sessions.map { |s| s['time'].to_i }
end

def session_browsers(user)
  user.sessions.map { |s| s['browser'].upcase }
end

def session_dates(user)
  user.sessions.map { |s| s['date'] }.sort.reverse!
end

def work(filename = 'data.txt')
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users = users << parse_user(cols) if cols[0] == 'user'
    sessions = sessions << parse_session(cols) if cols[0] == 'session'
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

  def collect_stats_from_users(users)
    stats = {}
    users.each do |user|
      session_times = session_times(user)
      session_browsers = session_browsers(user)
      user_name = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
      stats[user_name] =
        {
          # Собираем количество сессий по пользователям
          'sessionsCount' => user.sessions.count,
          # Собираем количество времени по пользователям
          'totalTime' => session_times.sum.to_s + ' min.',
          # Выбираем самую длинную сессию пользователя
          'longestSession' => session_times.max.to_s + ' min.',
          # Браузеры пользователя через запятую
          'browsers' => session_browsers.sort.join(', '),
          # Хоть раз использовал IE?
          'usedIE' => session_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
          # Всегда использовал только Chrome?
          'alwaysUsedChrome' => session_browsers.all? { |b| b =~ /CHROME/ },
          # Даты сессий через запятую в обратном порядке в формате iso8601
          'dates' => session_dates(user)
        }
    end
    stats
  end
  report = {}

  report['totalUsers'] = users.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = Set.new
  sessions.each do |session|
    browser = session['browser']
    uniqueBrowsers.add(browser)
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  users_objects = []

  sessions_by_users = sessions.group_by { |s| s['user_id'] }
  users.each do |user|
    user_sessions = sessions_by_users[user['id']].to_a
    user_object = User.new(attributes: user, sessions: user_sessions)
    users_objects << user_object
  end

  report['usersStats'] = collect_stats_from_users(users_objects)

  File.write('result.json', "#{Oj.dump(report)}\n")
end

