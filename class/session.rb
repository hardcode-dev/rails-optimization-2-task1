class Session

  attr_reader :browser, :time, :date

  def initialize(browser, time, date)
    @browser = browser
    @time = time
    @date = date.strip
  end
end
