# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_small.txt', disable_gc: true)
end
printer = RubyProf::FlatPrinter.new(result)
system('mkdir -p reports/ruby_prof_reports')
printer.print(File.open("reports/ruby_prof_reports/flat.txt", "w+"))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("reports/ruby_prof_reports/graph.html", "w+"))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby_prof_reports/callstack.html', 'w+'))

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => "reports/ruby_prof_reports", :profile => 'callgrind')

