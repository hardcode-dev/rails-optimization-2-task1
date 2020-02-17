require 'ruby-prof'
require_relative 'work_method.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_small.txt', disable_gc: true)
end

printer1 = RubyProf::GraphHtmlPrinter.new(result)
printer1.print(File.open("ruby_prof_reports/graph.html", "w+"))

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
