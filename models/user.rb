# frozen_string_literal: true

class User
  attr_reader :attributes, :sessions
  attr_accessor :browsers, :session_durations, :session_dates

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @sessions_count = 0
    @sessions_total_time = 0
    @session_durations = []
    @session_dates = []
    @longest_session = 0
    @used_ie = false
    @chrome_fan = true
    @browsers = []
  end

  def key
    @key ||= attributes['first_name'].to_s + ' ' + attributes['last_name'].to_s
  end

  def sessions_total_time
    "#{session_durations.reduce(0, :+)} min."
  end

  def longest_session
    "#{session_durations.max} min."
  end

  def browsers
    @browsers
  end

  def used_ie?
    browsers.any? { |b| b.start_with?('INTERNET EXPLORER') }
  end

  def chrome_fan?
    (sessions_count.positive? && browsers.all? { |b| b.start_with?('CHROME') })
  end

  def sessions_count
    @sessions.length
  end

  def user_stats
    { 'sessionsCount' => sessions_count,
      'totalTime' => sessions_total_time,
      'longestSession' => longest_session,
      'browsers' => browsers.sort.join(', '),
      'usedIE' => used_ie?,
      'alwaysUsedChrome' => chrome_fan?,
      'dates' => session_dates.sort.reverse }
  end
end
