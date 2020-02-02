class UserStats
  attr_reader :user, :user_times, :user_browsers

  def initialize(user)
    @user = user
    @user_times = user.sessions.map { |s| s.time.to_i }
    @user_browsers = user.sessions.map { |s| s.browser }
  end

  def user_stats
    {
      'sessionsCount' => sessions_count,
      'totalTime' => total_time,
      'longestSession' => longest_session,
      'browsers' => browsers,
      'usedIE' => used_ie,
      'alwaysUsedChrome' => always_used_chrome,
      'dates' => dates
    }
  end

  private

  def sessions_count
    user.sessions.count
  end

  def total_time
    "#{user_times.sum.to_s} min."
  end

  def longest_session
    "#{user_times.max.to_s} min."
  end

  def browsers
    user_browsers.sort.join(', ')
  end

  def used_ie
    user_browsers.any? { |b| b.start_with?('INTERNET EXPLORER') }
  end

  def always_used_chrome
    user_browsers.all? { |b| b.start_with?('CHROME') }
  end

  def dates
    user.sessions.map { |s| s.date }.sort.reverse
  end
end
