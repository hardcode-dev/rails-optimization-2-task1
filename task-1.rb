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

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
  end
end

def work(filename)
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(line) if cols[0] == 'user'
    sessions << parse_session(line) if cols[0] == 'session'
  end

  report = {}

  report[:totalUsers] = users.count

  unique_browsers = sessions.each_with_object([]) do |session, result|
    browser = session['browser']
    result << browser
    result
  end.uniq

  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  users_objects = []

  # предварительно проиндексировал
  sessions_index = sessions.each_with_object({}) do |session, index|
    index[session['user_id']] = [] unless index[session['user_id']]
    index[session['user_id']] << session
    index[session['user_id']]
  end

  users.each do |user|
    attributes = user

    id = user['id']
    user_sessions = sessions_index[id]

    next if user_sessions.nil? # Например, если выделить 200к записей, то последним будет юзер без сессий

    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects << user_object
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    {
      'sessionsCount' => user.sessions.count, # Собираем количество сессий по пользователям
      'totalTime' => user.sessions.map { |s| s['time'].to_i }.sum.to_s + ' min.', # Собираем количество времени по пользователям
      'longestSession' => user.sessions.map { |s| s['time'].to_i }.max.to_s + ' min.', # Выбираем самую длинную сессию пользователя
      'browsers' => user.sessions.map { |s| s['browser'].upcase }.sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase.match?(/INTERNET EXPLORER/) }, # Хоть раз использовал IE?
      'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase.match?(/CHROME/) }, # Всегда использовал только Chrome?
      'dates' => user.sessions.map { |s| s['date'] }.sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
