require 'set'

class Report
  attr_reader :sessions_stats
  def initialize
    @users_stats = {}
    @sessions_stats = init_session_stats
  end

  def commit_user
    return unless cur_user_stats

    cur_user_stats[:totalTime] = "#{cur_user_stats[:totalTime]} min."
    cur_user_stats[:longestSession] = "#{cur_user_stats[:longestSession]} min."
    cur_user_stats[:browsers] = cur_user_stats[:browsers].sort.join(', ')
    cur_user_stats[:dates] = cur_user_stats[:dates].to_a.sort { |d1, d2| d2 <=> d1 }
  end

  def commit_session
    sessions_stats[:allBrowsers] = sessions_stats[:allBrowsers].to_a.join(',')
  end

  def add_user(attributes)
    @cur_user_stats = init_user_stats
    users_stats[:"#{attributes[2]} #{attributes[3]}"] = cur_user_stats
    sessions_stats[:totalUsers] += 1
  end

  def update_session_stat(browser)
    sessions_stats[:totalSessions] += 1
    iterate = sessions_stats[:allBrowsers].add?(browser.upcase)
    sessions_stats[:uniqueBrowsersCount] += 1 if iterate
  end

  def update_user_stat(attributes)
    browser = attributes[3].upcase
    time = attributes[4].to_i
    date = attributes[5].strip

    cur_user_stats[:sessionsCount] += 1
    cur_user_stats[:totalTime] += time
    cur_user_stats[:longestSession] = time if time> cur_user_stats[:longestSession]
    cur_user_stats[:browsers] << browser
    cur_user_stats[:usedIE] = true if browser.match? /INTERNET EXPLORER/
    cur_user_stats[:alwaysUsedChrome] = false unless browser.match? /CHROME/
    cur_user_stats[:dates] << date
  end

  def commit_stats
    commit_user.then { commit_session }
  end

  private

  attr_reader :cur_user_stats, :users_stats

  def init_session_stats
    {
      totalUsers: 0,
      uniqueBrowsersCount: 0,
      totalSessions: 0,
      allBrowsers: SortedSet.new,
      usersStats: users_stats
    }
  end

  def init_user_stats
    {
      sessionsCount: 0,
      totalTime: 0,
      longestSession: 0,
      browsers: [],
      usedIE: false,
      alwaysUsedChrome: true,
      dates: Set.new
    }
  end
end