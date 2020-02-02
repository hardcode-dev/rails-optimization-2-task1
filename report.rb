class Report
  attr_reader :users, :sessions, :browsers, :unique_browsers

  def initialize(users, sessions)
    @users = users
    @sessions = sessions
    @browsers = sessions.map { |s| s.browser }
    @unique_browsers = Set.new(browsers)
  end

  def generate
    {
      'totalUsers' => users.count,
      'uniqueBrowsersCount' => unique_browsers.count,
      'totalSessions' => sessions.count,
      'allBrowsers' => unique_browsers.sort.join(','),
      'usersStats' => user_stats
    }
  end

  private

  def group_by_user_id_sessions
    @group_sessions ||= sessions.group_by { |s| s.user_id }
  end

  def users_objects
    @users_objects ||= users.map do |user|
      User.new(user, user_sessions(user))
    end
  end

  def user_sessions(user)
    group_by_user_id_sessions[user.id] || []
  end

  def user_stats
    users_objects.map { |user| [user.full_name, UserStats.new(user).user_stats] }.to_h
  end
end
