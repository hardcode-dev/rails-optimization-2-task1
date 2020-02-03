# frozen_string_literal: true
require 'json'
require 'byebug'

def work(file_name: 'files/data.txt', rows_count: nil)
  @users = []
  @total_users = 0
  @unique_browsers_count = 0
  @total_sessions = 0
  @all_browsers = []

  file_lines = parse_file(file_name, rows_count)

  file_lines.each { |line| parse_line(line) }

  @report = {
    totalUsers: @total_users,
    uniqueBrowsersCount: @all_browsers.uniq.count,
    totalSessions: @total_sessions,
    allBrowsers: @all_browsers.uniq.sort.join(','),
    usersStats: prepare_user_statistic
  }

  File.write('files/result.json', "#{@report.to_json}\n")
end

def parse_file(file_name, rows_count)
  rows_count ? File.read('files/data_large.txt').split("\n").first(rows_count) : File.read(file_name).split("\n")
end

def parse_line(line)
  cols = line.split(',')
  cols.first == 'user' ? parse_user(cols[1].to_i, cols) : parse_session(cols)
end

def parse_user(id, user)
  if @users[id].nil?
    @users[id] = [user[2], user[3], 0, 0, 0, [], []]
  else
    @users[id][0] = user[2]
    @users[id][1] = user[3]
  end
  @total_users += 1
end

def parse_session(session)
  browser = session[3].upcase
  @all_browsers << browser
  @total_sessions += 1

  collect_statistics(session[1].to_i, session[4].to_i, browser, session[5])
end

def collect_statistics(id, time, browser, date)
  @users[id] = [nil, nil, 0, 0, 0, [], []] if @users[id].nil?
  @users[id][2] += 1
  @users[id][3] += time
  @users[id][4] = time if time > @users[id][4]
  @users[id][5] << browser
  @users[id][6] << date
end

def prepare_user_statistic
  @users.each_with_object({}) { |user, result| result["#{user[0]} #{user[1]}"] = statistic_for_user(user) }
end

def statistic_for_user(user_array)
  {
    sessionsCount: user_array[2],
    totalTime: "#{user_array[3]} min.",
    longestSession: "#{user_array[4]} min.",
    browsers: user_array[5].sort.join(', '),
    usedIE: !user_array[5].find { |browser| browser =~ /INTERNET EXPLORER/ }.nil?,
    alwaysUsedChrome: user_array[5].all? { |browser| browser =~ /CHROME/ },
    dates: user_array[6].sort.reverse
  }
end
