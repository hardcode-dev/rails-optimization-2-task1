# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

def parse_user(user_fields)
  {
    'id' => user_fields[1],
    'first_name' => user_fields[2],
    'last_name' => user_fields[3],
  }
end

def parse_session(session_fields)
  {
    'user_id' => session_fields[1],
    'browser' => session_fields[3].upcase,
    'time' => session_fields[4].to_i,
    'date' => session_fields[5],
  }
end

def collect_stats_from_users(report, users, sessions_by_users, &block)
  users.each do |user|
    user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(sessions_by_users[user['id']]))
  end
end

def user_use_only_chrome?(browsers)
  uniq_browsers_of_user = browsers.uniq
  uniq_browsers_of_user.length == 1 && uniq_browsers_of_user.first =~ /CHROME/
end

def user_sessions_data(sessions)
  user_browsers = []
  user_sessions_dates = []
  user_sessions_times = []

  sessions.map do |session|
    user_browsers << session['browser']
    user_sessions_dates << session['date']
    user_sessions_times << session['time']
  end

  {
    browsers: user_browsers,
    sessions_dates: user_sessions_dates,
    sessions_times: user_sessions_times
  }
end

def work(file_name, disable_gc)
  GC.disable if disable_gc

  file_lines = File.read(file_name).split("\n").map { |line| line.split(',') }

  users = []
  sessions_by_users = {}

  file_lines.each do |cols|
    users << parse_user(cols) if cols[0] == 'user'

    if cols[0] == 'session'
      session = parse_session(cols)

      sessions_by_users[session['user_id']] ||= []
      sessions_by_users[session['user_id']] << session
    end
  end

  totalSessions = sessions_by_users.values.flatten
  uniqueBrowsers = totalSessions.map{|s| s["browser"]}.uniq
  report = {}

  report[:totalUsers] = users.count

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = totalSessions.count

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users, sessions_by_users) do |sessions|
    user_sessions_data = user_sessions_data(sessions)
    {
      'sessionsCount' => sessions.count,
      'totalTime' => user_sessions_data[:sessions_times].sum.to_s + ' min.',
      'longestSession' => user_sessions_data[:sessions_times].max.to_s + ' min.',
      'browsers' => user_sessions_data[:browsers].sort.join(', '),
      'usedIE' => user_sessions_data[:browsers].any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => user_use_only_chrome?(user_sessions_data[:browsers]),
      'dates' => user_sessions_data[:sessions_dates].sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work("data.txt", true)
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end

  def test_work_method_time_workins
    start_time = Time.now
    work("data_large.txt", true)
    end_time = Time.now
    expected_result = Time.now - start_time

    assert expected_result < 35
  end
end
