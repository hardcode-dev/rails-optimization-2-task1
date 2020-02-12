# Deoptimized version of homework task

require 'json'
require 'pry'

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
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user[:attributes]['first_name']} #{user[:attributes]['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(block.call(user))
  end
end

def work(filename='data.txt', disable_gc: false)
  GC.disable if disable_gc
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users.push(parse_user(cols))
    when 'session'
      sessions.push(parse_session(cols))
    end
  end

  report = {}

  report[:totalUsers] = users.count


  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map{|s| s['browser']}.uniq.sort
  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.join(',')


  # Статистика по пользователям
  users_objects = []
  grouped_sessions = sessions.group_by{|s| s['user_id']}

  users.each do |user|
    attributes = user
    user_sessions = grouped_sessions[user['id']]
    user_object = {attributes: attributes, sessions: user_sessions}
    users_objects.push(user_object)
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    # Собираем количество сессий по пользователям
    { 'sessionsCount' => user[:sessions].count ,
    # Собираем количество времени по пользователям
    'totalTime' => "#{user[:sessions].map {|s| s['time']}.sum} min." ,
    # Выбираем самую длинную сессию пользователя
    'longestSession' => "#{user[:sessions].map {|s| s['time']}.max} min." ,
    # Браузеры пользователя через запятую
    'browsers' => user[:sessions].map{|s| s['browser']}.sort.join(', ') ,
    # Хоть раз использовал IE?
    'usedIE' => user[:sessions].map{|s| s['browser'].match?(/INTERNET EXPLORER/) }.any? ,
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => user[:sessions].all?{|s| s['browser'].match?(/CHROME/) } ,
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => user[:sessions].map{|s| s['date']}.sort.reverse }
  end

  File.write('result.json', "#{report.to_json}\n")
end
