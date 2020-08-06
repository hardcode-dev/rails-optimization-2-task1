# Deoptimized version of homework task

require 'date'
require 'pry'
require 'json'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def collect_stats_from_user(report, user)
  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
  sessions = user.sessions
  browsers = sessions.map {|s| s['browser'].upcase}.sort
  time = sessions.map {|s| s['time'].to_i}
  report[:usersStats][user_key] = {
    'sessionsCount' => sessions.count,
    'totalTime' => time.sum.to_s + ' min.',
    'longestSession' => time.max.to_s + ' min.',
    'browsers' => browsers.join(', '),
    'usedIE' => browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
    'alwaysUsedChrome' => browsers.all? { |b| b.start_with?('CHROME') },
    'dates' => sessions.map{|s| s['date']}.sort.reverse
  }
end

def work(file, disable_gc: false)
  GC.disable if disable_gc

  report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: nil, usersStats: {} }
  uniqueBrowsers = []
  user = nil

  File.readlines('data/' + file).each do |line|
    fields = line.strip.split(',')

    if fields[0] == 'user'
      attrs = {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4],
      }
      collect_stats_from_user(report, user) unless user.nil?
      user = User.new(attributes: attrs, sessions: [])
      report[:totalUsers] += 1
    else
      session = {
        'user_id' => fields[1],
        'session_id' => fields[2],
        'browser' => fields[3],
        'time' => fields[4],
        'date' => fields[5],
      }
      user.sessions << session
      report[:totalSessions] += 1
      uniqueBrowsers << fields[3]
    end
  end
  collect_stats_from_user(report, user) unless user.nil?

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

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers.uniq!
  report[:uniqueBrowsersCount] = uniqueBrowsers.count
  report[:allBrowsers] = uniqueBrowsers.sort.join(',').upcase

  File.write('result.json', "#{report.to_json}\n")
end
