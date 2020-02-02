# frozen_string_literal: true

# Deoptimized version of homework task
require 'oj'
require 'set'


class Work

  attr_accessor :report

  def initialize(filename)
    @filename = filename

    @report = {}
    @user_stats = {}
    @user_id_name_map = {}

    @unique_browsers = SortedSet.new
  end

  def parse_user(fields)

    name = fields[2] + ' ' + fields[3]

    @user_id_name_map[fields[1]] = name

    @user_stats[name] = {
        'sessionsCount' => 0,
        'totalTime' => 0,
        'longestSession' => 0,
        'browsers' => [],
        'usedIE' => false,
        'alwaysUsedChrome' => true,
        'dates' => SortedSet.new
    }

  end


  def parse_session(fields)

    # {
    #     user_id: cols[1],
    #     session_id: cols[2],
    #     browser: cols[3].upcase,
    #     time: cols[4].to_i,
    #     date: cols[5]
    # }


    user_name = @user_id_name_map[fields[1]]

    stats = @user_stats[user_name]

    stats['sessionsCount'] += 1

    time = fields[4].to_i

    stats['totalTime'] += time
    stats['longestSession'] = time if time > stats['longestSession']

    stats['dates'].add(fields[5])

    browser = fields[3].upcase
    @unique_browsers.add(browser)
    stats['usedIE'] ||= !browser['INTERNET EXPLORER'].nil?
    stats['browsers'] << browser
    stats['alwaysUsedChrome'] &&= !browser['CHROME'].nil?


  end

  def work
    file_lines = File.read(@filename).split("\n")


    sessions_count = 0

    file_lines.each do |line|
      cols = line.split(',')

      if cols[0] == 'session'
        sessions_count += 1
        parse_session(cols)
      elsif cols[0] == 'user'
        parse_user(cols)
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


    report[:totalUsers] = @user_id_name_map.count


    report['uniqueBrowsersCount'] = @unique_browsers.count
    report['totalSessions'] = sessions_count
    report['allBrowsers'] = @unique_browsers.to_a.join(',')


    @user_stats.each do |user_name, stats|
      @user_stats[user_name]['totalTime'] = "#{@user_stats[user_name]['totalTime']} min."
      @user_stats[user_name]['longestSession'] = "#{@user_stats[user_name]['longestSession']} min."
      @user_stats[user_name]['browsers'] = @user_stats[user_name]['browsers'].sort.join(', ')
      @user_stats[user_name]['dates'] = @user_stats[user_name]['dates'].to_a.reverse


    end



    report['usersStats'] = @user_stats
    Oj.mimic_JSON()
    File.write('result.json', Oj.dump(report) + "\n")
  end
end
