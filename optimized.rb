# Deoptimized version of homework task

require 'json'
require 'date'
require_relative 'user'

class ParserOptimized
  class << ParserOptimized
    DATES_CACHE = { }

    def parse_date(date)
      DATES_CACHE[date] ||= Date.strptime(date, '%Y-%m-%d').iso8601
    end

    def parse_user(fields)
      {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
      }
    end

    def parse_session(fields)
      {
        'user_id' => fields[1],
        'session_id' => fields[2],
        'browser' => fields[3].upcase,
        'time' => fields[4].to_i,
        'date' => parse_date(fields[5]),
      }
    end

    def collect_stats_from_users(report, users_objects, &block)
      users_objects.each do |user|
        user_key = user['first_name'] + ' ' + user['last_name']
        report['usersStats'][user_key] ||= {}
        report['usersStats'][user_key].merge!(block.call(user))
      end
    end

    def work(filename = 'data_large.txt')
      users = []
      sessions = []
      unique_browsers = {}
      report = {}

      File.foreach(filename) do |line|
        cols = line.split(',')
        if cols[0] == 'user'
          users << parse_user(cols)
        end

        if cols[0] == 'session'
          session = parse_session(cols)
          sessions << session
          unique_browsers[session['browser'].upcase] = 1
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

      report[:totalUsers] = users.length

      # # Подсчёт количества уникальных браузеров
      # uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq

      report['uniqueBrowsersCount'] = unique_browsers.keys.length

      report['totalSessions'] = sessions.length

      report['allBrowsers'] = unique_browsers.keys.sort.join(',')

      # Статистика по пользователям
      # users_objects = []

      sessions_by_user = sessions.group_by { |session| session['user_id'] }

      # users.each do |user|
      #   attributes = user
      #   user_sessions = sessions_by_user[user['id']] || []
      #   user_object = User.new(attributes: attributes, sessions: user_sessions)
      #   users_objects << user_object
      # end

      report['usersStats'] = {}

      collect_stats_from_users(report, users) do |user|
        user_sessions = sessions_by_user[user['id']] || []
        user_browsers = user_sessions.map { |s| s['browser'] }
        session_times = user_sessions.map { |s| s['time'] }
        {
          # Собираем количество сессий по пользователям
          'sessionsCount' => user_sessions.length,
          # Собираем количество времени по пользователям
          'totalTime' => session_times.sum.to_s + ' min.',
          # Выбираем самую длинную сессию пользователя
          'longestSession' => session_times.max.to_s + ' min.',
          # Браузеры пользователя через запятую
          'browsers' => user_browsers.sort.join(', '),
          # Хоть раз использовал IE?
          'usedIE' => user_browsers.any? { |b| b.start_with? 'INTERNET EXPLORER' },
          # Всегда использовал только Chrome?
          'alwaysUsedChrome' => user_browsers.all? { |b| b.start_with? 'CHROME' },
          # Даты сессий через запятую в обратном порядке в формате iso8601
          'dates' => user_sessions.map {|s| s['date']}.sort.reverse
        }
      end

      File.write('result.json', "#{report.to_json}\n")
    end
  end
end
