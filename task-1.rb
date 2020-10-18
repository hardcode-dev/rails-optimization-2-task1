# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'benchmark/ips'

require_relative 'user'
# require_relative 'test_me'

class Report

  def call(file_name = 'data_256000.txt')
    work(file_name)
  end

  def parse_user(fields)
    {
        :id => fields[1],
        :first_name => fields[2],
        :last_name => fields[3],
        :age => fields[4],
    }
  end

  def parse_session(fields)
    {
        :user_id => fields[1],
        :session_id => fields[2],
        :browser => fields[3],
        :time => fields[4],
        :date => fields[5],
    }
  end

  # def collect_stats_from_users(report, users_objects, &block)
  #   # TODO: rewrite this method to be called once for user.
  #   users_objects.each do |user|
  #     user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"
  #     report['usersStats'][user_key] ||= {}
  #
  #     new_info = block.call(user)
  #     report['usersStats'][user_key] = report['usersStats'][user_key].merge(new_info)
  #   end
  # end

  def uniq_browsers_fast(browsers_dict)
    result = browsers_dict.keys
    result.sort!
  end

  def uniq_browsers_slow(sessions)
    result = []
    sessions.each do |session|
      browser = session[:browser]
      result += [browser] if result.all? { |b| b != browser }
    end
    result
  end

  def file_lines_arr(file_name)
    file_lines = File.read(file_name).split("\n")
    file_lines
  end

  def collect_info_from_file(file_lines)
    users = []
    sessions = []
    sessions_by_user = {}
    uniq_browsers_dict = {}

    file_lines.each do |line|
      # user,76,Jerome,Corene,46
      # session,76,0,Chrome 23,42,2017-05-03
      fields = line.split(',')

      if fields[0] == 'user'
        user_obj = parse_user(fields)
        users << user_obj
      end

      if fields[0] == 'session'
        session_obj = parse_session(fields)
        sessions << session_obj

        user_id = session_obj[:user_id]
        sessions_by_user[user_id] = [] unless sessions_by_user[user_id]
        sessions_by_user[user_id] << session_obj

        browser = session_obj[:browser]
        uniq_browsers_dict[browser] = true
      end
    end

    # Good enough for now.
    return users, sessions, sessions_by_user, uniq_browsers_dict
  end

  def users_to_objects(users_arr, sessions_by_user)
    result = []

    counter = 0
    chunk_size = 10000

    users_arr.each do |user|
      attributes = user

      user_id = user[:id]
      user_sessions = sessions_by_user[user_id]

      user_object = User.new(attributes: attributes, sessions: user_sessions)
      result << user_object
      # result = result + [user_object] # this line is bad, mkay. Very slow.
      #
      # counter += 1
      #
      # if counter % chunk_size == 0
      #   puts "#{counter} Objects created"
      # end
    end

    result
  end

  def all_browsers_list(sessions)
    sessions
      .map { |s| s[:browser] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')
  end

  def all_browsers_list_fast(unique_browsers_dict)
    list_arr = unique_browsers_dict.keys
    list_arr
      .sort
      .map { |b| b.upcase }
      .join(',')
  end

  def work(file_name)

    with_logging = (file_name == 'data_large.txt')
    puts " Start" if with_logging
    file_lines = file_lines_arr(file_name)

    users = []
    sessions = []
    sessions_by_user = {}
    uniq_browsers_dict = {}

    puts " collect_info_from_file" if with_logging
    users, sessions, sessions_by_user, uniq_browsers_dict = collect_info_from_file(file_lines)

    puts " collect_info_from_file END" if with_logging

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

    report[:totalUsers] = users.count

    # Подсчёт количества уникальных браузеров
    # uniqueBrowsers = uniq_browsers_slow(sessions)

    puts " uniq_browsers_fast" if with_logging
    uniqueBrowsers = uniq_browsers_fast(uniq_browsers_dict)
    puts " uniq_browsers_fast END" if with_logging

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    # TODO: can we just use uniqBrowsersList here?
    # report['allBrowsers'] = all_browsers_list(sessions)
    report['allBrowsers'] = all_browsers_list_fast(uniq_browsers_dict)

    # Статистика по пользователям
    # users_objects = []

    puts " users_to_objects" if with_logging
    users_objects = users_to_objects(users, sessions_by_user)
    puts " users_to_objects END" if with_logging

    # report['usersStats'] = generate_report_old(nil, users_objects)

    puts " generate_report_fast" if with_logging
    report['usersStats'] = generate_report_fast(users_objects)
    puts " generate_report_fast END" if with_logging

    # puts "### Completed, write to file"
    File.write('result.json', "#{report.to_json}\n")
  end



  def generate_report_old(full_report, users_objects)
    report = {}
    report['usersStats'] = {}

    # Собираем количество сессий по пользователям
    report_sessions_count(report, users_objects)
    # Собираем количество времени по пользователям
    report_user_time(report, users_objects)
    # Выбираем самую длинную сессию пользователя
    report_longest_session(report, users_objects)
    # Браузеры пользователя через запятую
    report_user_browsers(report, users_objects)
    # Хоть раз использовал IE?
    report_did_use_ie(report, users_objects)
    # Всегда использовал только Chrome?
    report_always_chrome(report, users_objects)
    # Даты сессий через запятую в обратном порядке в формате iso8601
    report_session_dates(report, users_objects)

    report['usersStats']
  end

  def generate_single_user_info(sessions)
    sessions_count = sessions.count

    total_time = 0
    longest_session = 0

    browsers_arr = []
    used_ie = false
    always_chrome = true

    dates_arr = []

    sessions.each do |s|
      time = s[:time].to_i
      browser = s[:browser].upcase

      total_time += time
      longest_session = time if time > longest_session

      unless used_ie
        bool_ie = browser.upcase =~ /INTERNET EXPLORER/
        if bool_ie
          used_ie = true
          always_chrome = false
        end
      end

      if always_chrome
        bool_chrome = browser.upcase =~ /CHROME/
        always_chrome = false unless bool_chrome
      end

      dates_arr << s[:date]
      browsers_arr << browser
    end

    # {
    #   'sessionsCount' => user.sessions.count
    #
    #   { 'totalTime' => user.sessions.map {|s| s[:time]}.map {|t| t.to_i}.sum.to_s + ' min.' }
    #   { 'longestSession' => user.sessions.map {|s| s[:time]}.map {|t| t.to_i}.max.to_s + ' min.' }
    #
    #   { 'browsers' => user.sessions.map {|s| s[:browser]}.map {|b| b.upcase}.sort.join(', ') }
    #   { 'usedIE' => user.sessions.map{|s| s[:browser]}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    #   { 'alwaysUsedChrome' => user.sessions.map{|s| s[:browser]}.all? { |b| b.upcase =~ /CHROME/ } }
    #
    #   { 'dates' => user.sessions.map{|s| s[:date]}.sort.reverse }
    # }

    {
      'sessionsCount' => sessions_count,
      'totalTime' => total_time.to_s + ' min.'.freeze,
      'longestSession' => longest_session.to_s + ' min.'.freeze,
      'browsers' => browsers_arr.sort.join(', '),
      'usedIE' => used_ie,
      'alwaysUsedChrome' => always_chrome,
      'dates' => dates_arr.sort.reverse
    }
  end

  def generate_report_fast(users_objects)
    users_stats = {}

    users_objects.each do |user|
      user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"

      # users_stats[user_key] ||= {}

      user_info = generate_single_user_info(user.sessions)
      users_stats[user_key] = user_info
    end

    users_stats
  end

  def report_sessions_count(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end
  end

  def report_user_time(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime' => user.sessions.map {|s| s[:time]}.map {|t| t.to_i}.sum.to_s + ' min.' }
    end
  end

  def report_longest_session(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession' => user.sessions.map {|s| s[:time]}.map {|t| t.to_i}.max.to_s + ' min.' }
    end
  end

  def report_user_browsers(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers' => user.sessions.map {|s| s[:browser]}.map {|b| b.upcase}.sort.join(', ') }
    end
  end

  def report_did_use_ie(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE' => user.sessions.map{|s| s[:browser]}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end
  end

  def report_always_chrome(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.map{|s| s[:browser]}.all? { |b| b.upcase =~ /CHROME/ } }
    end
  end

  def report_session_dates(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      # dates = user.sessions
      #           .map {|s| s[:date]}
      #           .map {|d| Date.parse(d)}
      #           .sort
      #           .reverse
      #           .map { |d| d.iso8601 }

      # Looks like dates are already on format we want to be in report
      # No need to parse it.
      # Revise later if needed.
      dates = user.sessions.map{|s| s[:date]}.sort.reverse

      { 'dates' => dates }
    end
  end

end

#
#
# Report.new.call(nil)