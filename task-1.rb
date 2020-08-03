# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'
require 'oj'


def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
    sessions: [],
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4].to_i,
    date: fields[5],
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user[:first_name]} #{user[:last_name]}"
    browsers = user[:sessions].map { |s| s[:browser].upcase }.sort!
    report[:usersStats][user_key] = {
      # Собираем количество сессий по пользователям
      sessionsCount: user[:sessions].count,
      # Собираем количество времени по пользователям
      totalTime: "#{user[:sessions].sum { |s| s[:time] }} min.",
      # Выбираем самую длинную сессию пользователя
      longestSession: "#{user[:sessions].max { |a, b| a[:time] <=> b[:time] }&.[](:time)} min.",
      # Браузеры пользователя через запятую
      browsers: browsers.join(', '),
      # Хоть раз использовал IE?
      usedIE: browsers.any? { |b| b =~ /INTERNET EXPLORER/i },
      # Всегда использовал только Chrome?
      alwaysUsedChrome: browsers.all? { |b| b =~ /CHROME/i },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      dates: user[:sessions].map { |s| s[:date] }.sort.reverse!,
    }
  end
end


def work(filename, disable_gc: false)
  GC.disable if disable_gc
  file_lines = File.read(filename).split("\n")

  users = []
  user = {}

  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: nil,
    usersStats: {},
  }

  unique_browsers = Set.new

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      user = parse_user(cols)
      users << user
    end
    if cols[0] == 'session'
      session = parse_session(cols)
      report[:totalSessions] += 1
      user[:sessions] << session
      unique_browsers.add(session[:browser])
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

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  collect_stats_from_users(report, users)

  File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end

