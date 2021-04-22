# frozen_string_literal: true

class User
  attr_reader :attributes, :sessions, :key, :total_session_time, :max_session_time, :browsers, :ie, :chrome

  def initialize(attributes)
    @attributes = attributes
    @sessions = []
    @browsers = []
    @ie = false
    @chrome = nil
    @total_session_time = 0
    @max_session_time = 0
    @key = "#{attributes['first_name']} #{attributes['last_name']}".freeze
  end

  def add_session(session)
    session_time = session.delete('time').to_i
    @total_session_time += session_time
    @max_session_time = session_time if @max_session_time < session_time

    browser = session['browser']
    @browsers.push browser unless @browsers.include?(browser)

    @sessions.push session
  end
end