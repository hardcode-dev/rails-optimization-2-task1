# Optimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'
require 'minitest/autorun'

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4].chomp
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3],
    'time' => session[4],
    'date' => session[5]
  }
end

def work(file: nil, disable_gc: false)
  GC.disable if disable_gc

  file ||= ARGV[0]
  file_lines = File.readlines(file)
  users ||= {}
  report = {}
  session_count = 0
  unique_browser_set ||= Set.new
  session_dates = Hash.new { |h, date| h[date] = Date.strptime(date, '%Y-%m-%d') }

  file_lines.each do |line|
    cols = line.split(',')

    if line.start_with?('user')
      users[cols[1]] = parse_user(cols)

      next
    end

    session = parse_session(cols)
    session_count += 1
    unique_browser_set << session['browser']

    users[cols[1]][:sessions] ||= []
    users[cols[1]][:sessions] << session
  end

  report['totalUsers'] = users.count
  report['uniqueBrowsersCount'] = unique_browser_set.count
  report['totalSessions'] = session_count
  report['allBrowsers'] = unique_browser_set.map(&:upcase).sort.join(',')
  report['usersStats'] ||= {}

  users.each_key do |user_id|
    user_key = "#{users[user_id]['first_name']} #{users[user_id]['last_name']}"
    normalized_sessions ||= []
    common_report ||= {}
    common_report[:user_session_seconds] ||= []
    common_report[:user_session_browsers] ||= []
    common_report[:reversed_session_dates] ||= []

    users[user_id][:sessions].each do |session|
      common_report[:user_session_seconds] << session['time'].to_i
      common_report[:user_session_browsers] << session['browser']
      normalized_sessions << session['browser'].upcase
      common_report[:reversed_session_dates] << session_dates[session['date'].chomp].iso8601
    end

    report['usersStats'][user_key] = {
      'sessionsCount' => users[user_id][:sessions].count,
      'totalTime' => common_report[:user_session_seconds].sum.to_s + ' min.',
      'longestSession' => common_report[:user_session_seconds].max.to_s + ' min.',
      'browsers' => normalized_sessions.sort.join(', '),
      'usedIE' => normalized_sessions.any? { |b| b.match?(/INTERNET EXPLORER/) },
      'alwaysUsedChrome' => normalized_sessions.all? { |b| b.match?(/CHROME/) },
      'dates' => common_report[:reversed_session_dates].sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end

# work if ARGV[0]
