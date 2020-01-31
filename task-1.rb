# frozen_string_literal: true

# Deoptimized version of homework task

require 'minitest/autorun'
require 'oj'

class User
  attr_accessor :id, :user_key, :sessionsCount, :longestSession, :totalTime,
                :browsers, :dates, :use_ie, :only_chrome

  def initialize(id, user_key, _sessionsCount = 0, _longestSession = 0, _totalTime = 0, _browsers = [], _dates = [], _use_ie = false, _only_chrome = true)
    @id = id
    @user_key = user_key
    @sessionsCount = 0
    @longestSession = 0
    @totalTime = 0
    @browsers = []
    @dates = []
    @use_ie = false
    @only_chrome = true
  end

  def formated_dates
    dates.sort!.reverse!
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'user_key' => "#{fields[2]} #{fields[3]}"
  }
end

def parse_session(fields)
  {
    'browser' => fields[3],
    'time' => fields[4].to_i,
    'date' => fields[5].delete!("\n")
  }
end

def default_settings
  @report = {}
  @report['totalUsers'] = 0
  @report['uniqueBrowsersCount'] = 0
  @report['totalSessions'] = 0
  @report['allBrowsers'] = []

  @report['usersStats'] = {}
  @temp_user = nil
end

def user_action(cols)
  send_to_report if @temp_user

  user_params = parse_user(cols)
  @temp_user = User.new(user_params['id'], user_params['user_key'])
  @report['totalUsers'] += 1
end

def sessions_action(cols)
  session = parse_session(cols)
  @temp_user.sessionsCount += 1

  @temp_user.totalTime += session['time']
  if @temp_user.longestSession <= session['time']
    @temp_user.longestSession = session['time']
  end
  @temp_user.dates << session['date']
  @temp_user.browsers << session['browser']

  @temp_user.use_ie = true if session['browser'] =~ /Internet Explorer/
  @temp_user.only_chrome = false unless session['browser'] =~ /Chrome/

  @report['allBrowsers'] << session['browser']

  @report['totalSessions'] += 1
end

def send_to_report
  @report['usersStats'].merge!(serialized_to_report(@temp_user))
end

def serialized_to_report(user)
  {
    user.user_key => { 'sessionsCount' => user.sessionsCount,
                       'totalTime' => "#{user.totalTime} min.",
                       'longestSession' => "#{user.longestSession} min.",
                       'browsers' => user.browsers.map!(&:upcase).sort!.join(', '),
                       'usedIE' => user.use_ie,
                       'alwaysUsedChrome' => user.only_chrome,
                       'dates' => user.formated_dates }
  }
end

def work(file_name)
  default_settings

  File.open(file_name, 'r').each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user_action(cols)
    else
      sessions_action(cols)
    end
  end

  @report['allBrowsers'].sort!.uniq!
  @report['uniqueBrowsersCount'] = @report['allBrowsers'].count

  @report['allBrowsers'] = @report['allBrowsers'].map!(&:upcase).join(',')

  send_to_report

  File.write('result.json', Oj.dump(@report) + "\n")
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
    work('data.txt')
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
