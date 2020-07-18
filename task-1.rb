# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = user.attributes['first_name'].to_s + ' ' + user.attributes['last_name'].to_s
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
  end
end

def work(filename = 'data.txt')
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users += [parse_user(line)] if cols[0] == 'user'
    sessions += [parse_session(line)] if cols[0] == 'session'
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
    .map { |s| s['browser'] }
    .map { |b| b.upcase }
    .sort
    .uniq
    .join(',')

  # Статистика по пользователям
  users_objects = []

  sessions_by_user = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user
    user_object = User.new(attributes: attributes, sessions: sessions_by_user[user['id']])
    users_objects += [user_object]
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    sessions_times = user.sessions.map { |s| s['time'].to_i }
    browsers = user.sessions.map { |s| s['browser']&.upcase }.sort

    {
        # Собираем количество сессий по пользователям
        'sessionsCount': user.sessions.count,
        # Собираем количество времени по пользователям
        'totalTime': "#{sessions_times.sum} min.",
        # Выбираем самую длинную сессию пользователя
        'longestSession': "#{sessions_times.max} min.",
        # Браузеры пользователя через запятую
        'browsers': browsers.join(', '),
        # Хоть раз использовал IE?
        'usedIE': browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
        # Всегда использовал только Chrome?
        'alwaysUsedChrome': browsers.all? { |b| b =~ /CHROME/ },
        # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates': user.sessions.map { |s| Date.iso8601(s['date']) }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
