# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'benchmark'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME

# GC.disable

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
      id: fields[1],
      first_name: fields[2],
      last_name: fields[3],
      age: fields[4],
  }
end

def parse_session(fields)
  {
      user_id: fields[1],
      session_id: fields[2],
      browser: fields[3],
      browser_upcase: fields[3].upcase,
      time: fields[4],
      time_to_i: fields[4].to_i,
      date: fields[5].chomp!
  }
end

def parse_file(file)
  report = {}
  report[:totalUsers] = 0
  report['uniqueBrowsersCount'] = {}
  report['totalSessions'] = 0
  report['allBrowsers'] = {}
  report['usersStats'] = {}

  users = []
  user_sessions_hash = {}

  File.foreach(file) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
      report[:totalUsers] += 1
    end
  end

  File.foreach(file) do |line|
    cols = line.split(',')
    if cols[0] == 'session'
      session = parse_session(cols)

      report['totalSessions'] += 1
      report['uniqueBrowsersCount'][session[:browser]] = true
      report['allBrowsers'][session[:browser_upcase]] = true

      (user_sessions_hash[session[:user_id]] ||= []) << session
    end
  end

  report['uniqueBrowsersCount'] = report['uniqueBrowsersCount'].count
  report['allBrowsers'] = report['allBrowsers'].keys.sort.join(',')



  users.each do |user|
    user_sessions = user_sessions_hash[user[:id]]
    user = User.new(attributes: user, sessions: user_sessions)
    user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"
    report['usersStats'][user_key] = collect_stats_from_user(user)
  end


  report
end

def collect_stats_from_user(user)
  user_report = {}

  user_report['sessionsCount'] = 0
  user_report['totalTime'] = []
  user_report['longestSession'] = []
  user_report['browsers'] = []
  user_report['usedIE'] = false
  user_report['alwaysUsedChrome'] = true
  user_report['dates'] = []

  user.sessions.each do |session|
    # Собираем количество сессий по пользователям
    user_report['sessionsCount'] += 1
    user_report['totalTime'] << session[:time_to_i]
    user_report['longestSession'] << session[:time_to_i]
    user_report['browsers'] << session[:browser_upcase]
    unless user_report['usedIE']
      user_report['usedIE'] = (session[:browser_upcase] =~ /INTERNET EXPLORER/) ? true : false
    end
    if user_report['alwaysUsedChrome']
      user_report['alwaysUsedChrome'] = (session[:browser_upcase] =~ /CHROME/) ? true : false
    end
    user_report['dates'] << session[:date]
  end

  # Собираем количество времени по пользователям
  user_report['totalTime'] = user_report['totalTime'].sum.to_s + ' min.'
  # Выбираем самую длинную сессию пользователя
  user_report['longestSession'] = user_report['longestSession'].max.to_s + ' min.'
  # Браузеры пользователя через запятую
  user_report['browsers'] = user_report['browsers'].sort.join(', ')
  # Даты сессий через запятую в обратном порядке в формате iso8601
  user_report['dates'] = user_report['dates'].sort!.reverse!

  user_report
end

def work(file = 'data.txt')

  report = parse_file(file)

  result_file_name = file == 'data.txt' ? 'result.json' : "#{file}.json"

  File.write(result_file_name, "#{report.to_json}\n")
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
    work
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end

if ARGV.any?
  puts "process #{ARGV.first} ..."
  time = Benchmark.realtime do
    result = RubyProf.profile do
      work(ARGV.first)
    end
    printer = RubyProf::CallStackPrinter.new(result)
    printer.print(File.open('ruby_prof_reports/call_stack.html', 'w+'))

    printer4 = RubyProf::CallTreePrinter.new(result)
    printer4.print(:path => "ruby_prof_reports", :profile => 'callgrind')
  end
  puts "... processed #{ARGV.first} in #{time} sec"
else
  puts 'no file to process'
end
