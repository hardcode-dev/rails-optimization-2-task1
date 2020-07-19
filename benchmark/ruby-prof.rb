require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(file_name: './tmp/data_100000.txt', disable_gc: true)
end

system('rm -rf reports/ruby_prof')
system('mkdir -p reports/ruby_prof')

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/ruby_prof/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/ruby_prof/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby_prof/callstack.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports/ruby_prof', profile: 'callgrind')
