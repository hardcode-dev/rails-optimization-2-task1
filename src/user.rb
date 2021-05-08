# frozen_string_literal: true

class User
  attr_reader :attributes, :sessions, :sessions_count, :total_time, :longest_session, :browsers, :used_ie, :always_used_chrome, :dates

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions

    reset_parameters
  end

  def reset_parameters
    @sessions_count = 0
    @total_time = 0
    @longest_session = 0
    @browsers = []
    @used_ie = false
    @always_used_chrome = false
    @dates = []
  end

  def calculate_parameters
    reset_parameters
    return unless @sessions.size

    used_chrome = false
    used_another_browser = false
    @sessions.each do |session|
      @sessions_count += 1

      time = session['time']
      @total_time += time
      @longest_session = time if @longest_session < time

      browser = session['browser']
      @browsers.push(browser)
      @used_ie = true if !@used_ie && browser =~ /INTERNET EXPLORER/
      if browser =~ /CHROME/
        used_chrome = true
      else
        used_another_browser = true
      end

      @dates.push(session['date'])
    end
    @always_used_chrome = used_chrome && !used_another_browser
  end
end
