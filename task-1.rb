# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

class User
  attr_reader :attributes

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @all_sessions = sessions
  end

  def sessions
    @sessions ||= @all_sessions[attributes['id']]
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(src:, dest:)
  file_lines = File.read(src).split("\n")

  report = {}

  totalUsers = 0
  totalSessions = 0
  uniqueBrowsers = Set.new

  users_objects = []
  sessions = Hash.new { |hash, user_id| hash[user_id] = [] }

  file_lines.each do |line|
    cols = line.split(',')

    case cols[0]
    when 'user'
      user = parse_user(cols)
      users_objects << User.new(attributes: user, sessions: sessions)

      totalUsers += 1
    when 'session'
      session = parse_session(cols)
      sessions[session['user_id']] << session

      totalSessions += 1
      uniqueBrowsers << session['browser'].upcase
    end
  end

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
  report['totalUsers'] = totalUsers
  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = totalSessions
  report['allBrowsers'] = uniqueBrowsers.to_a.sort.join(',')
  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
      'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
      # Браузеры пользователя через запятую
      'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map{|s| s['date']}.sort { |a, b| b <=> a }
    }
  end

  File.write(dest, "#{report.to_json}\n")
end
