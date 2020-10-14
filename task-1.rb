# frozen_string_literal: true

require 'ruby-progressbar'
require 'set'
require 'oj'
require_relative 'models/user'

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
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def report_user(prev_user, users_stats)
  users_stats[prev_user.key] ||= {}
  users_stats[prev_user.key] = users_stats[prev_user.key].merge(prev_user.user_stats)
end

def work(file_path = 'files/data.txt')
  puts 'Started'

  file_lines = File.read(file_path).split("\n")
  sessions_count = 0
  users_count = 0
  browsers = SortedSet.new
  browsers_count = 0

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
  users = {}
  users_stats = {}
  progressbar = ProgressBar.create(format: "%a %e %b\u{15E7}%i %p%% %t",
                                   progress_mark: ' ',
                                   remainder_mark: "\u{FF65}",
                                   title: 'Importing data',
                                   total: file_lines.length)
  prev_user = nil
  file_lines.each do |line|
    fields = line.split(',')
    if fields[0] == 'user'
      user = User.new(attributes: parse_user(fields), sessions: [])
      users[fields[1]] = user
      users_count += 1
      unless prev_user.eql?(user)
        # form report for previously imported user
        report_user(prev_user, users_stats) if prev_user
        prev_user = user
      end
    end

    if fields[0] == 'session'
      user = users[fields[1]]
      user.sessions << parse_session(fields)
      user.browsers << fields[3].upcase
      browsers << fields[3].upcase
      browsers_count += 1
      user.session_durations << fields[4].to_i
      user.session_dates << fields[5]
      sessions_count += 1
    end

    progressbar.increment
  end
  # reporting last user
  report_user(prev_user, users_stats)

  report['totalUsers'] = users.length
  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = browsers.length
  report['totalSessions'] = sessions_count
  report['allBrowsers'] = browsers.to_a.join(',')
  # Статистика по пользователям
  report['usersStats'] = users_stats
  File.write('result.json', "#{Oj.dump(report)}\n")
  puts 'Finished!'
end

work
