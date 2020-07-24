require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME
# profile the code
result = RubyProf.profile do
  work
end

# print a flat profile to text

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_report/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_report/callstack.html', 'w+'))
