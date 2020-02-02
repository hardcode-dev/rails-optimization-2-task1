require 'json'
require 'set'
require 'oj'

require_relative 'user.rb'
require_relative 'user_attributes.rb'
require_relative 'user_stats.rb'
require_relative 'session.rb'
require_relative 'report.rb'

def work(file_name = 'data.txt', disable_gc: true)
  GC.disable if disable_gc

  users = []
  sessions = []

  file_lines = File.readlines(file_name, chomp: true)

  file_lines.each do |line|
    line = line.split(',')
    users.push(UserAttributes.new(*line)) if line[0] == 'user'
    sessions.push(Session.new(*line)) if line[0] == 'session'
  end

  File.write('result.json', "#{Oj.dump(Report.new(users, sessions).generate)}\n")
end
