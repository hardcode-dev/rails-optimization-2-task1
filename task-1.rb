# Deoptimized version of homework task
require 'json'
require 'csv'
require 'set'

def parse_user(fields)
  {
    user_attributes: { 
      id: fields[1],
      first_name: fields[2],
      last_name: fields[3],
      age: fields[4]
    },
    total_time: 0,
    sessions_count: 0,
    longest_session: 0,
    browsers: [],
    dates: []
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |_, user_data|
    user_key = "#{user_data[:user_attributes][:first_name]} #{user_data[:user_attributes][:last_name]}"
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key] = report[:usersStats][user_key].merge(yield(user_data))
  end
end

def work(file_name: 'data.txt', disable_gc: false)
  GC.disable if disable_gc

  users = {}
  report = {}
  report[:totalUsers] = 0
  report[:uniqueBrowsersCount] = 0
  report[:totalSessions] = 0
  unique_browsers = Set.new

  CSV.foreach(file_name) do |line|
    if line[0] == 'user'
      users[line[1].to_i] = parse_user(line)
      report[:totalUsers] += 1
    else
      user_id = line[1].to_i
      time = line[4].to_i
      browser = line[3].upcase
      users[user_id][:browsers] << browser
      users[user_id][:total_time] += time
      users[user_id][:longest_session] = time if users[user_id][:longest_session] < time
      users[user_id][:dates] << line[5]
      users[user_id][:sessions_count] += 1
      unique_browsers.add(browser)
      report[:totalSessions] += 1
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

  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.sort.join(',')

  report[:usersStats] = {}

  # Собираем количество сессий по пользователям
  # Собираем количество времени по пользователям
  # Выбираем самую длинную сессию пользователя
  # Браузеры пользователя через запятую
  # Хоть раз использовал IE?
  # Всегда использовал только Chrome?
  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users) do |user_data|
    { sessionsCount: user_data[:sessions_count],
      totalTime: user_data[:total_time].to_s + ' min.',
      longestSession: user_data[:longest_session].to_s + ' min.',
      browsers: user_data[:browsers].sort.join(', '),
      usedIE: user_data[:browsers].any? { |b| b =~ /INTERNET EXPLORER/ },
      alwaysUsedChrome: user_data[:browsers].all? { |b| b =~ /CHROME/ },
      dates: user_data[:dates].sort.reverse }
  end

  File.write('result.json', "#{report.to_json}\n")
end
