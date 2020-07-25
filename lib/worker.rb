require_relative './user'
require 'json'
require 'ruby-progressbar'

class Worker
  def initialize(file_path, progress_bar = false)
    @is_progress_bar = progress_bar
    @file_path = file_path
    @users = {}

    @unique_browsers = []
    @sessions_count = 0

    init_progress_bar if @is_progress_bar
  end

  def run
    parsing_file
    report_build
  end

  private

  def init_progress_bar
    @progress_bar = ProgressBar.create(
      total: nil,
      throttle_rate: 0.25,
      length: 80,
      format: '%t: |%W| %a'
    )
  end

  def report_build
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
    #

    report = {}
    report[:totalUsers] = @users.count

    if @is_progress_bar
      @progress_bar.progress = 0
      @progress_bar.title = 'Формирование отчета..'
      @progress_bar.total = report[:totalUsers] + 1
    end

    report['uniqueBrowsersCount'] = @unique_browsers.count
    report['totalSessions'] = @sessions_count
    report['allBrowsers'] = @unique_browsers.sort.join(',')
    report['usersStats'] = {}

    @users.each do |_user_id, user|
      report['usersStats'][user.key] = {
        sessionsCount: user.sessions_count,
        totalTime: "#{user.total_time} min.",
        longestSession: "#{user.longest_session} min.",
        browsers: user.browsers.sort.join(', '),
        usedIE: user.used_ie?,
        alwaysUsedChrome: user.used_only_chrome?,
        dates: user.last_session_dates,
      }
      @progress_bar.increment if @is_progress_bar
    end

    File.write('result.json', "#{report.to_json}\n")
  end

  def read_file
    IO.readlines(@file_path)
  end

  def parsing_file
    file_lines = read_file

    @progress_bar.title = 'Загрузка файла...' if @is_progress_bar
    file_lines.each do |line|
      cols = line.split(',')

      @users[cols[1]] ||= User.new(cols[1])

      if cols[0] == 'session'
        @sessions_count += 1

        browser = cols[3].upcase

        @users[cols[1]].add_session(browser, cols[4].to_i, cols[5].strip)
        @unique_browsers << browser
      elsif cols[0] == 'user'
        @users[cols[1]].set_info(cols[2], cols[3])
        @progress_bar.increment if @is_progress_bar
      end
    end

    @unique_browsers.uniq!
  end
end
