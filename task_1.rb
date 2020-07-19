# frozen_string_literal: true

require 'json'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5]
  }
end

def work(params = {})
  users = []
  sessions = []

  File.read(params[:file]).split("\n").each do |line|
    cols = line.split(',')
    users << parse_user(line) if cols[0] == 'user'
    sessions << parse_session(line) if cols[0] == 'session'
  end

  report = {}

  report['totalUsers'] = users.count

  unique_browsers = sessions.each_with_object([]) do |session, result|
    result << session[:browser]
  end.uniq

  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers.sort.map(&:upcase).join(',')

  user_sessions_structure = sessions.each_with_object(Hash.new { |h, k| h[k] = [] }) do |session, mapping|
    mapping[session[:user_id]] << session
  end

  report['usersStats'] = {}
  users.each do |user|
    user_sessions = user_sessions_structure[user[:id]]
    user_key = "#{user[:first_name]} #{user[:last_name]}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!({
        sessionsCount: user_sessions.count,
        totalTime: user_sessions.map { |s| s[:time].to_i }.sum.to_s + ' min.',
        longestSession: user_sessions.map { |s| s[:time].to_i }.max.to_s + ' min.',
        browsers: user_sessions.map { |s| s[:browser].upcase }.sort.join(', '),
        usedIE: user_sessions.map { |s| s[:browser] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        alwaysUsedChrome: user_sessions.map { |s| s[:browser] }.all? { |b| b.upcase =~ /CHROME/ },
        dates: user_sessions.map { |s| s[:date] }.sort.reverse
      })
  end
  

  File.write('result.json', "#{report.to_json}\n")
end