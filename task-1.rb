# frozen_string_literal: true

require 'oj'

def parse_user(fields)
  {
    'id' => fields[1],
    'user_key' => "#{fields[2]} #{fields[3]}"
  }
end

def parse_session(fields)
  {
    'browser' => fields[3].upcase!,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def work(file_name = 'data.txt')
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []
  unique_browsers = {}
  sessions_by_user_id = {}

  report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: nil, usersStats: {} }

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(cols)
      report[:totalUsers] += 1
    when 'session'
      session = parse_session(cols)
      sessions << session
      browser = session['browser']
      user_id = cols[1]
      sessions_by_user_id[user_id] ||= []
      sessions_by_user_id[user_id] << session
      unique_browsers[browser] = nil
      report[:totalSessions] += 1
    end
  end

  unique_browsers = unique_browsers.keys.sort!

  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.join(',')

  # Статистика по пользователям
  users.each do |user|
    user_sessions = sessions_by_user_id[user['id']]

    time_sum = 0
    longest_session = 0
    browsers = []
    dates = []

    user_sessions.each do |s|
      time = s['time']
      browser = s['browser']
      time_sum += time
      longest_session = time if longest_session < time
      browsers << browser
      dates << s['date']
    end

    browsers.sort!

    report[:usersStats][user['user_key']] = {
      sessionsCount: user_sessions.count,
      totalTime: "#{time_sum} min.",
      longestSession: "#{longest_session} min.",
      browsers: browsers.join(', '),
      usedIE: browsers.any? { |b| b.start_with?('I') },
      alwaysUsedChrome: browsers.all? { |b| b.start_with?('C') },
      dates: dates.sort!.reverse!
    }
  end

  File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end
