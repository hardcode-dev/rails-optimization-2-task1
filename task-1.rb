require 'json'

IE_REGEXP = /INTERNET EXPLORER/.freeze
CHROME_REGEXP = /CHROME/.freeze

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
    time: fields[4].to_i,
    date: fields[5].chomp,
  }
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

def work(filepath = 'data.txt')
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: [],
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }
  user_keys = []

  File.foreach(filepath) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user = parse_user(cols)
      report[:totalUsers] += 1
      user_key = "#{user[:first_name]} #{user[:last_name]}"
      user_keys.pop          # хак для доступа к переменной вне цикла,
      user_keys << user_key  # ничего лучше не придумал
      report[:usersStats][user_key] = {
        sessionsCount: 0,
        totalTime: [],
        longestSession: [],
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: true,
        dates: []
      }
    end
    next if cols[0] != 'session'

    session = parse_session(cols)
    report[:totalSessions] += 1
    report[:allBrowsers] << session[:browser]

    user_key = user_keys.last
    report[:usersStats][user_key][:sessionsCount] += 1
    report[:usersStats][user_key][:totalTime] << session[:time]
    report[:usersStats][user_key][:browsers] << session[:browser]

    unless report[:usersStats][user_key][:usedIE]
      report[:usersStats][user_key][:usedIE] = IE_REGEXP.match?(session[:browser])
    end
    if report[:usersStats][user_key][:alwaysUsedChrome]
      report[:usersStats][user_key][:alwaysUsedChrome] = CHROME_REGEXP.match?(session[:browser])
    end
    report[:usersStats][user_key][:dates] << session[:date]
  end

  report[:uniqueBrowsersCount] = report[:allBrowsers].uniq.count
  report[:allBrowsers] = report[:allBrowsers].uniq.sort.join(',')

  report[:usersStats].each_value do |user_hash|
    user_hash[:longestSession] = "#{user_hash[:totalTime].max} min."
    user_hash[:totalTime] = "#{user_hash[:totalTime].sum} min."
    user_hash[:browsers] = user_hash[:browsers].sort.join(', ')
    user_hash[:dates] = user_hash[:dates].sort!.reverse!
  end

  File.write('result.json', "#{report.to_json}\n")
end
