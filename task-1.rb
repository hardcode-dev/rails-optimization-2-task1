# Deoptimized version of homework task
require 'json'
require 'date'
require 'ruby-progressbar'

def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work filename = 'data.txt'
  puts "start work..."
  file_lines = File.read(filename).split("\n")

  progressbar = ProgressBar.create(
    total: file_lines.size,
    format: '%a, %J, %E, %B'
  ) if ProgressBarEnabler.show?

  users = []
  sessions = {}
  allBrowsers = []
  allSessionCount = 0
  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      sessions[cols[1]] = {
        "user_id" =>  "#{cols[2]}" + ' ' + "#{cols[3]}",
        "sessions" => []
      }
    end
    if cols[0] == 'session'
      allSessionCount += 1
      ses = parse_session(cols)
      sessions[ses['user_id']]['sessions'] << ses
      allBrowsers << ses['browser']
    end
    progressbar.increment if ProgressBarEnabler.show?
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

  report[:totalUsers] = sessions.keys().count

  
  progressbar = ProgressBar.create(
    total: allSessionCount,
    format: '%a, %J, %E, %B'
  ) if ProgressBarEnabler.show?

  report['uniqueBrowsersCount'] = allBrowsers.uniq.count

  report['totalSessions'] = allSessionCount

  report['allBrowsers'] =
    allBrowsers
    .sort
    .uniq
    .join(',')
  
  users_objects = []

  progressbar = ProgressBar.create(
    total: sessions.keys().size,
    format: '%a, %J, %E, %B'
  ) if ProgressBarEnabler.show?

  # Статистика по пользователям
  report['usersStats'] = {}
  sessions.each do |user_id, sessions_info|
    user_sessions = sessions_info['sessions']
    user_key = sessions_info['user_id']
    report['usersStats'][user_key] ||= {}
    date_a = browser_a = time_a = []
    user_sessions.map do |s| 
      time_a = time_a + [s['time'].to_i]
      browser_a = browser_a + [s['browser']]
      date_a = date_a + [s['date']]
    end

    reports = {
        'sessionsCount' => user_sessions.count,
        'totalTime' =>  (time_a.sum.to_s + ' min.'),
        'longestSession' => (time_a.max.to_s + ' min.'),
        'browsers' => browser_a.sort.join(', '),
        'usedIE' => browser_a.any? { |b| b =~ /INTERNET EXPLORER/ },
        'alwaysUsedChrome' => browser_a.all? { |b| b =~ /CHROME/ },
        'dates' => date_a.sort.reverse
    }
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(reports)


    progressbar.increment if ProgressBarEnabler.show?
  end

  File.write('result.json', "#{report.to_json}\n")
end
class ProgressBarEnabler
  @@flag = true
  def self.enable!
    @@flag = true
  end
  def self.disable!
    @@flag = false
  end  
  def self.show?
    @@flag
  end
end

ProgressBarEnabler.disable!
=begin
require 'benchmark'
t = Benchmark.realtime do 
  #work('data/data_large.txt')
  work('data/data30000.txt')
end
p t
=end
