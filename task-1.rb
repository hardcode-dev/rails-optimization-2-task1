# Deoptimized version of homework task

require 'json'
require 'pry'
require 'oj'

require 'benchmark/ips'

class Work
  attr_accessor :report, :users

  def initialize
    @report = {}
    @users = {}
  end

  def work(filename = 'data.txt', disable_gc: false)
    GC.disable if disable_gc

    file_lines = File.read(filename).split("\n")
    parse_filelines(file_lines)
    make_report
  end

  def parse_filelines(file_lines)
    lines = file_lines.map { |line| line.split(',') }
    grouped_file_lines = lines.group_by { |line| line[0] }
    grouped_file_lines['user'].each { |user| users[user[1]] = user[2] + ' ' + user[3] }
    @users = grouped_file_lines['session'].group_by { |line| line[1] }.transform_keys { |k| users[k] }
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
  #
  def make_report
    count_users
    count_uniq_browsers
    count_sessions
    set_all_browsers
    set_users_stats
    write_report
  end

  def count_users
    report[:totalUsers] = users.count
  end

  # Подсчёт количества уникальных браузеров
  #
  def count_uniq_browsers
    @uniq_browsers = users.values.flatten(1).flat_map { |i| i[3].upcase }.uniq
    report[:uniqueBrowsersCount] = @uniq_browsers.count
  end

  def count_sessions
    report[:totalSessions] = users.values.flatten(1).count
  end

  def set_all_browsers
    report[:allBrowsers] = @uniq_browsers.sort.join(',')
  end

  # Статистика по пользователям
  #
  def set_users_stats
    report[:usersStats] = {}
    users.each do |name, value|
      times = value.map { |i| i[4].to_i }
      browsers = value.map { |i| i[3].upcase }
      joined_browsers = browsers.sort.join(', ')
      report[:usersStats][name] = {
        sessionsCount: times.count,
        totalTime: times.sum.to_s + ' min.',
        longestSession: times.max.to_s + ' min.',
        browsers: joined_browsers,
        usedIE: joined_browsers.include?('INTERNET EXPLORER'),
        alwaysUsedChrome: browsers.all? { |b| b.start_with?('CHROME') },
        dates: value.map { |i| i[5] }.sort.reverse
      }
    end
  end

  def write_report
    File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
  end
end

# Benchmark.ips do |x|
#   x.config(
#     stats: :bootstrap,
#     confidence: 95
#   )
#
#   x.report('task-1') do
#     Work.new.work('data_large.txt')
#   end
# end
