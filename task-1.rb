require 'json'
require 'pry'
require 'date'

def collect_stats_from_users(report, stat_name, &block)
  @users_objects.each do |user|
    user_key = "#{user['first_name']} #{user['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key][stat_name] = block.call(user)
  end
end

def parse_data(data)
  ind = 0
  size = data.size

  while true
    if data[ind] == 'USER'
      unless @last_user.nil?
        @last_user['dates'].sort!.reverse!
      end

      @last_user = {
        'id' => data[ind + 1],
        'first_name' => data[ind + 2].capitalize,
        'last_name' => data[ind + 3].capitalize,
        'age' => data[ind + 4],
        'browsers' => [],
        'durations' => [],
        'use_ie' => false,
        'use_only_chrome' => true,
        'dates' => [],
        'sessions_count' => 0
      }
      @users_objects << @last_user

      ind += 5
    else
      @last_user['sessions_count'] += 1

      browser = data[ind + 3]
      @last_user['browsers'] << browser
      @last_user['use_ie'] = true if browser.start_with?('INTERNET')
      @last_user['use_only_chrome'] = false if @last_user['use_only_chrome'] || !browser.start_with?('CHROME')

      @all_browsers[browser] = nil

      @last_user['durations'] << data[ind + 4].to_i
      @last_user['dates'] << data[ind + 5]

      @sessions_count +=1

      ind += 6
    end

    if ind >= size
      @last_user['dates'].sort!.reverse!
      break
    end
  end
end

def work(file_path, gc_disable = false)
  GC.disable if gc_disable

  @users_objects = []
  @sessions_count = 0
  @all_browsers = {}

  data = File.read(file_path).gsub("\n", ',').upcase.split(',')
  parse_data(data)

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

  report[:totalUsers] = @users_objects.count

  report['uniqueBrowsersCount'] = @all_browsers.keys.size

  report['totalSessions'] = @sessions_count

  report['allBrowsers'] = @all_browsers.keys.sort.join(',')

  # Статистика по пользователям

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, 'sessionsCount') do |user|
    user['sessions_count']
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, 'totalTime') do |user|
    "#{user['durations'].sum} min."
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, 'longestSession') do |user|
    "#{user['durations'].max} min."
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, 'browsers') do |user|
    user['browsers'].sort.join(', ')
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, 'usedIE') do |user|
    user['use_ie']
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, 'alwaysUsedChrome') do |user|
    user['use_only_chrome']
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, 'dates') do |user|
    user['dates']
  end

  File.write('data_files/result.json', "#{report.to_json}\n")
end
