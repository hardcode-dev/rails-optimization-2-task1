# frozen_string_literal: true

# About:
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


# Optimized version of homework task
# task1 - $ruby -r "./lib/optimization.rb.rb" -e "Optimization.call" 'Optimization::TaskOne' 'work' \
# 'false,data/data_large.txt'

module Optimization
  require 'json'
  require 'pry'
  require 'oj'
  require 'benchmark'

  module_function

  class User
    attr_reader :attributes, :sessions

    def initialize(attributes:, sessions:)
      @attributes = attributes
      @sessions = sessions
    end
  end

  module TaskOne
    extend self

    def work(path, gcl = nil)
      GC.disable if gcl

      users, sessions = load_file(path)

      report = {}

      report['totalUsers'] = users.count

      unique_browsers = sessions.map { |d| d['browser'] }.uniq

      report['uniqueBrowsersCount'] = unique_browsers.size

      report['totalSessions'] = sessions.count

      report['allBrowsers'] = unique_browsers.sort.join(',')

      # Статистика по пользователям
      report['usersStats'] = {}

      sessions = sessions.group_by { |session| session['user_id'] }

      users.each do |attributes|
        collect_stats_from_user(report, User.new(attributes: attributes, sessions: sessions[attributes['id']]))
      end

      write_file(report)
    end

    private

    def parse_user(fields)
      {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4]
      }
    end

    def parse_session(fields)
      {
        'user_id' => fields[1],
        'session_id' => fields[2],
        'browser' => fields[3].upcase,
        'time' => fields[4],
        'date' => fields[5][0..-2]
      }
    end

    def collect_stats_from_user(report, user)
      user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

      sessions_dates = []
      browsers ||= user.sessions.map { |s| s['browser'] }
      time ||= user.sessions.map { |s| s['time'].to_i }

      user.sessions.each do |s|
        sessions_dates << s['date']
      end

      report['usersStats'][user_key] = {
        # Собираем количество сессий по пользователям
        'sessionsCount' => user.sessions.count,
        # Собираем количество времени по пользователям
        'totalTime' => "#{time.sum} min.",
        # Выбираем самую длинную сессию пользователя
        'longestSession' => "#{time.max} min.",
        # Браузеры пользователя через запятую
        'browsers' => browsers.sort.join(', '),
        # Хоть раз использовал IE?
        'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
        # Всегда использовал только Chrome?
        'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
        # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates' => sessions_dates.sort.reverse
      }
    end

    def load_file(path)
      users = []
      sessions = []

      File.readlines(path).each do |line|
        cols = line.split(',')
        if cols[0] == 'user'
          users << parse_user(cols)
        else
          sessions << parse_session(cols)
        end
      end

      [users, sessions]
    end

    def write_file(report)
      File.write('result.json', "#{Oj.dump(report)}\n")
    end
  end

  def call
    class_name, method_name, args = ARGV
    arguments = args.split(',')

    GC.disable if arguments[0] == 'true'

    time = Benchmark.measure do
      class_name.split('::').reduce(Module, :const_get).send(method_name.to_sym, arguments[1])
    end
    puts "Runtime: #{time.real.round(2)} seconds"
  end
end



