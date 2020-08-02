# frozen_string_literal: true

# Deoptimized version of homework task

require 'oj'
require_relative 'lib/user'

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2].capitalize,
    last_name: fields[3].capitalize,
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4].to_i,
    date: fields[5]
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = user.attributes[:first_name] + ' ' + user.attributes[:last_name]
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
  end
end

def work(path)
  file_lines = File.read("#{path}.txt").upcase.split("\n")

  users = []
  browsers = []
  sessions = {}
  sessions_count = 0

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'USER'

    next unless cols[0] == 'SESSION'

    session = parse_session(cols)
    sessions_count += 1
    sessions[session[:user_id]] ||= []
    sessions[session[:user_id]] << session

    browsers << session[:browser]
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

  report['totalUsers'] = users.count

  # Подсчёт количества уникальных браузеров
  filtered_browsers = browsers.sort.uniq

  report['uniqueBrowsersCount'] = filtered_browsers.length
  report['totalSessions'] = sessions_count
  report['allBrowsers'] = filtered_browsers.join(',')

  # Статистика по пользователям
  users_objects = users.map { |user| User.new(attributes: user, sessions: sessions[user[:id]] || []) }

  report['usersStats'] = {}

  # Состовляем отчёт где:
  # {
  #   'sessionsCount'    => 'Собираем количество сессий по пользователям',
  #   'totalTime'        => 'Собираем количество времени по пользователям',
  #   'longestSession'   => 'Выбираем самую длинную сессию пользователя',
  #   'browsers'         => 'Браузеры пользователя через запятую',
  #   'usedIE'           => 'Хоть раз использовал IE?',
  #   'alwaysUsedChrome' => 'Всегда использовал только Chrome?',
  #   'dates'            => 'Даты сессий через запятую в обратном порядке в формате iso8601'
  # }

  collect_stats_from_users(report, users_objects) do |user|
    sessions_times = user.sessions.map { |s| s[:time] }
    sessions_browsers = user.sessions.map { |s| s[:browser] }

    {
      'sessionsCount' => user.sessions.length,
      'totalTime' => sessions_times.sum.to_s + ' min.',
      'longestSession' => sessions_times.max.to_s + ' min.',
      'browsers' => sessions_browsers.sort.join(', '),
      'usedIE' => sessions_browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
      'alwaysUsedChrome' => sessions_browsers.all? { |b| b.start_with?('CHROME') },
      'dates' => user.sessions.map { |s| s[:date] }.sort.reverse
    }
  end

  File.write("#{path}.json", "#{Oj.dump(report)}\n")
end
