# frozen_string_literal: true

require 'benchmark'
require 'ruby-prof'
require 'stackprof'
require_relative 'task-1'

user_counts = [10, 50, 100, 500, 1000, '_large']

GC.disable
user_counts.each do |count|
  next unless File.exist?("files/data#{count}.txt")

  user_time = Benchmark.realtime do
    work("files/data#{count}.txt")
  end
  puts "finished #{count} in #{user_time}"
end

StackProf.run(mode: :wall, out: 'stackprof_reports/sp.dump', interval: 1200) do
  work('files/data1000.txt')
end

RubyProf.measure_mode = RubyProf::WALL_TIME
result = RubyProf.profile do
  work('files/data1000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer2 = RubyProf::GraphHtmlPrinter.new(result)
printer3 = RubyProf::FlatPrinter.new(result)

printer.print(path: 'ruby_prof_report', profile: 'callgrid')
printer2.print(File.open('ruby_prof_report/graph.html', 'w+'))
printer3.print(STDOUT)
