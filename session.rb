class Session
  attr_reader :user_id, :session_id, :browser, :time, :date

  def initialize(_, user_id, session_id, browser, time, date)
    @user_id = user_id
    @session_id = session_id
    @browser = browser.upcase
    @time = time
    @date = date
  end
end
