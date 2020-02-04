# Deoptimized version of homework task
require 'oj'

class Report
  attr_reader :report, :last_user_name

  def initialize
    @report = {
      'totalUsers' => 0,
      'uniqueBrowsersCount' => 0,
      'totalSessions' => 0,
      'allBrowsers' => [],
      'usersStats' => {}
    }
    @last_user_name = nil
  end

  def work(filename: 'data.txt', disable_gc: true)
    file_lines = File.read(filename).split("\n")

    while file_lines.size > 0
      cols = file_lines.shift.split(',')
      case cols[0]
        when 'user' then
          user_key = "#{cols[2]} #{cols[3]}"
          parse_user(user_key)
          @last_user_name = user_key
        when 'session' then
          parse_session(cols[3].upcase, cols[4].to_i, cols[5])
      end
    end

    collect_stats_from_users

    uniq_browsers = report['allBrowsers'].flatten.uniq
    report['uniqueBrowsersCount'] = uniq_browsers.length
    report['allBrowsers'] = uniq_browsers.sort.join(',')

    File.write('result.json', "#{Oj.dump(report)}\n")
  end

  def parse_user(user_key)
    report['usersStats'][user_key] = {
      'sessionsCount' => 0,
      'totalTime' => 0,
      'longestSession' => 0,
      'browsers' => [],
      'usedIE' => false,
      'alwaysUsedChrome' => true,
      'dates' => []
    }
  end

  def parse_session(browser, session_time, date)
    user_data = report['usersStats'][last_user_name]

    user_data['sessionsCount'] += 1
    user_data['totalTime'] += session_time
    user_data['longestSession'] = session_time if session_time > user_data['longestSession']
    user_data['browsers'] << browser
    user_data['usedIE'] = true if !user_data['usedIE'] && browser.match?(/INTERNET EXPLORER/)
    user_data['alwaysUsedChrome'] = false if user_data['alwaysUsedChrome'] && !(browser.match?(/CHROME/))
    user_data['dates'] << date
  end

  def collect_stats_from_users
    report['usersStats'].each do |user_key, value|
      report['allBrowsers'] << value['browsers']
      report['totalSessions'] += value['sessionsCount']

      value['totalTime'] = "#{value['totalTime']} min."
      value['longestSession'] = "#{value['longestSession']} min."
      value['browsers'] = value['browsers'].sort.join(', ')
      value['dates'] = value['dates'].sort.reverse
    end

    report['totalUsers'] = report['usersStats'].length
  end
end
