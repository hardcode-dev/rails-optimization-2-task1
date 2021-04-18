# RubyProf Graph report
# ruby ruby-prof-graph.rb
# open ruby_prof_reports/graph.html
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('../data_assimpt.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("graph.html", "w+"))