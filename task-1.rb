# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'benchmark'
require_relative 'user'

class Parser
  class << Parser
    def parse_user(user)
      fields = user.split(',')
      parsed_result = {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4],
      }
    end

    def parse_session(session)
      fields = session.split(',')
      parsed_result = {
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

    def read_file(filename)
      File.read(filename).split("\n")
    end

    def work(filename = 'data_large.txt')
      users = []
      sessions = []

      read_file(filename).each do |line|
        cols = line.split(',')
        users = users + [parse_user(line)] if cols[0] == 'user'
        sessions = sessions + [parse_session(line)] if cols[0] == 'session'
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

      report = {}

      report[:totalUsers] = users.count

      # Подсчёт количества уникальных браузеров
      uniqueBrowsers = []
      sessions.each do |session|
        browser = session['browser']
        uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
      end

      report['uniqueBrowsersCount'] = uniqueBrowsers.count

      report['totalSessions'] = sessions.count

      report['allBrowsers'] =
        sessions
          .map { |s| s['browser'] }
          .map(&:upcase)
          .sort
          .uniq
          .join(',')

      # Статистика по пользователям
      users_objects = []

      users.each do |user|
        attributes = user
        user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
        user_object = User.new(attributes: attributes, sessions: user_sessions)
        users_objects = users_objects + [user_object]
      end

      report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end

      File.write('result.json', "#{report.to_json}\n")
    end
  end
end
