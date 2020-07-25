class User
  attr_reader :attributes, :sessions_count, :browsers

  def initialize(id)
    @id = id
    @first_name = ''
    @last_name = ''

    @sessions_count = 0
    @times = []
    @browsers = []
    @dates = []
  end

  def set_info(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def add_session(browser, time, date)
    # Собираем количество сессий по пользователям
    @sessions_count += 1

    @times << time
    @browsers << browser
    @dates << date
  end

  # Собираем количество времени по пользователям
  def total_time
    @times.sum
  end

  # Выбираем самую длинную сессию пользователя
  def longest_session
    @times.max
  end

  # Хоть раз использовал IE?
  def used_ie?
    @browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
  end

  # Всегда использовал только Chrome?
  def used_only_chrome?
    @browsers.all? { |b| b =~ /CHROME/ }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  def last_session_dates
    @dates.sort.reverse
  end

  def key
    "#{@first_name} #{@last_name}"
  end
end

