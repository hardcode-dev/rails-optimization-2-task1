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

require 'json'
require 'pry'
require 'date'
require 'oj'

class ReportGenerator
  attr_reader :sessions, :report, :uniq_browsers

  def initialize
    @report = {}
    @sessions = {}
    @uniq_browsers = {}
  end

  def add_object(fields)
    if fields[0] == 'user'
      @sessions[fields[1]] = {
        'name' => "#{fields[2]} #{fields[3]}",
        'sessions' => []
      }
    else
      @sessions[fields[1]]['sessions'] << {
        'browser' => fields[3].upcase,
        'time' => fields[4].to_i,
        'date' => fields[5],
      }
      @uniq_browsers[fields[3].upcase] = 1
    end
  end

  def fetch_uniq_browsers
    report['uniqueBrowsersCount'] = @uniq_browsers.size
  end

  def build_user_stat(user_sessions)
    user_browsers = user_sessions.map { |s| s['browser'] }
    session_times = user_sessions.map {|s| s['time']}
    {
      'sessionsCount' => user_sessions.count, # количество сессий по пользователям
      'totalTime' => "#{session_times.sum} min.", # количество времени по пользователям
      'longestSession' => "#{session_times.max} min.", # самая длинная сессию пользователя
      'browsers' => user_browsers.sort.join(', '), # браузеры пользователя через запятую
      'usedIE' => user_browsers.any?{|b| b.include?('INTERNET EXPLORER')}, # Хоть раз использовал IE?
      'alwaysUsedChrome' => user_browsers.all? { |b| b.include?('CHROME') }, # Всегда использовал только Chrome?
      'dates' => user_sessions.map{|s| s['date']}.sort.reverse! # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end


  def user_stats
    report['usersStats'] = {}

    sessions.values.each do |object|
      report['usersStats'][object['name']] = build_user_stat(object['sessions'])
    end
  end

  def fetch_total_users
    report['totalUsers'] = sessions.size
  end

  def fetch_total_sessions
    report['totalSessions'] = sessions.values.inject(0) { |sum, user| sum + user['sessions'].size }
  end

  def fetch_all_browsers
    report['allBrowsers'] = @uniq_browsers.keys.sort.join(',')
  end

  def read_file(input)
    file_lines = File.read(input).split("\n")

    file_lines.each do |line|
      add_object(line.split(','))
    end
  end

  def build_report
    fetch_total_users
    fetch_uniq_browsers
    fetch_total_sessions
    fetch_all_browsers
    user_stats
  end

  def save_output(output)
    File.write(output, "#{Oj.dump(report)}\n")
  end

  def work(input: 'data_large.txt', output: 'result_large.json', disable_gc: false)
    GC.disable if disable_gc
    read_file(input)
    build_report
    save_output(output)
  end
end


