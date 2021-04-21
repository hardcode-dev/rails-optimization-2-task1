# Deoptimized version of homework task

require 'pry'
require 'date'
require 'oj'

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4],
    date: fields[5],
  }
end

def work(from_file, to_file)
  file_lines = File.read(from_file).split("\n").sort

  sessions = { uniqueBrowsers: {}, totalSessions: 0 }
  report = { totalUsers: 0,
             uniqueBrowsersCount: nil,
             totalSessions: nil,
             allBrowsers: nil,
             usersStats: {} }

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      attributes = parse_user(cols)
      user_sessions = sessions[attributes[:id]]
      report[:totalUsers] += 1

      user_key = "#{attributes[:first_name]} #{attributes[:last_name]}"
      report[:usersStats][user_key] = 
        if user_sessions
          times = user_sessions.map {|s| s[:time]}.map {|t| t.to_i}
          browsers = user_sessions.map {|s| s[:browser]}

          { sessionsCount: user_sessions.count,
            totalTime: "#{times.sum.to_s} min.",
            longestSession: "#{times.max.to_s} min.",
            browsers: browsers.sort.join(', '),
            usedIE: browsers.any? { |b| b.start_with?('I') },
            alwaysUsedChrome: browsers.all? { |b| b.start_with?('C') },
            dates: user_sessions.map{|s| s[:date]}.sort.reverse }
        else
          {}
        end
    else
      session = parse_session(cols)
      user_id = session[:user_id]
      browser = session[:browser]

      sessions[user_id] ||= []
      sessions[user_id] << session
      sessions[:uniqueBrowsers][browser] ||= true
      sessions[:totalSessions] += 1
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

  # Подсчёт количества уникальных браузеров

  report[:uniqueBrowsersCount] = sessions[:uniqueBrowsers].keys.count

  report[:totalSessions] = sessions[:totalSessions]

  report[:allBrowsers] =
    sessions[:uniqueBrowsers]
      .keys
      .sort
      .join(',')

  File.write(to_file, "#{Oj.dump(report, mode: :compat)}\n")
end
