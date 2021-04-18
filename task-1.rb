# frozen_string_literal: true

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

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(block.call(user))
  end
end

USER = 'user'
SESSION = 'session'

def work(file_name)

  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when USER
      users << parse_user(cols)
    when SESSION
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

  # Статистика по пользователям и браузерам
  users_objects = []

  sessionsBrowsers = []
  users_sessions = []
  sessions.each do |session|
    id = session[:user_id].to_i
    users_sessions[id] ||= []
    users_sessions[id] << session

    sessionsBrowsers << session[:browser].upcase
  end

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessionsBrowsers.uniq
  report[:uniqueBrowsersCount] = uniqueBrowsers.count
  report[:totalSessions] = sessions.count
  report[:allBrowsers] = uniqueBrowsers.sort.join(',')

  users.each do |user|
    users_objects.push(User.new(attributes: user, sessions: users_sessions[user[:id].to_i]))
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    sessions_time_to_i = []
    sessions_browser = []
    sessions_dates = []
    user.sessions.each do |s|
      sessions_time_to_i << s[:time].to_i
      sessions_browser << s[:browser].upcase
      sessions_dates << s[:date]
    end
    { 'sessionsCount' => user.sessions.count,
      'totalTime' => sessions_time_to_i.sum.to_s + ' min.',
      'longestSession' => sessions_time_to_i.max.to_s + ' min.',
      'browsers' => sessions_browser.sort.join(', '),
      'usedIE' => sessions_browser.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => sessions_browser.all? { |b| b =~ /CHROME/ },
      'dates' => sessions_dates.sort.reverse  }
  end

  File.write('result.json', "#{report.to_json}\n")
end
