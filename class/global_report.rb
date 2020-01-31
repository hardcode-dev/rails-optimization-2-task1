class GlobalReport
  attr_reader :unique_browsers, :total_sessions, :total_time

  def initialize
    @unique_browsers = Set.new()
    @total_sessions = 0
    @total_time = 0
  end

  def process(session)
    @unique_browsers << session.browser

    @total_sessions +=1
    @total_time += session.time
  end
end
