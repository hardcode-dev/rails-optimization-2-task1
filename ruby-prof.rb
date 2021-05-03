require 'ruby-prof'
require_relative './task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(file: 'data100000.txt', disable_gc: true)
  # work(file: "data_large.txt", disable_gc: false)
end

printer = RubyProf::MultiPrinter.new(result, %i[flat graph graph_html tree call_info stack dot])
# printer.print(File.open("ruby_prof_reports/calltree.html", "w+"))

# CallTreePrinter
# printer.print(path: "ruby_prof_reports", profile: "callgrid")
# RubyProf::MultiPrinter
printer.print(path: 'ruby_prof_reports_multi', profile: 'profile')
