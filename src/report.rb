# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'ruby-progressbar'
require_relative 'user'

DATES = {}

def parse_date(date)
  DATES[date] ||= Date.strptime(date, '%Y-%m-%d').iso8601
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => parse_date(fields[5])
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file_name, lines_count = nil, progressbar_enabled = false)
  file_lines = File.read(file_name).split("\n") if progressbar_enabled

  users = []
  sessions = []

  progressbar = ProgressBar.create(total: file_lines.count, format: '%a, %J, %E %B') if progressbar_enabled

  i = 0
  File.foreach(file_name) do |line|
    i += 1
    break if lines_count && i == lines_count

    progressbar.increment if progressbar_enabled

    cols = line.split(',')
    users.push(parse_user(cols)) if cols[0] == 'user'
    sessions.push(parse_session(cols)) if cols[0] == 'session'
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
  uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq
  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям
  users_objects = []
  sessions_by_user = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = sessions_by_user[user['id']] || []
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    user_object.calculate_parameters
    users_objects.push(user_object)
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions_count,
      # Собираем количество времени по пользователям
      'totalTime' => user.total_time.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
      'longestSession' => user.longest_session.to_s + ' min.',
      # Браузеры пользователя через запятую
      'browsers' => user.browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => user.used_ie,
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user.always_used_chrome,
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.dates.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
