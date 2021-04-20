require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

RubyProf.start

work(ENV['FILENAME'] || 'data.txt')

result = RubyProf.stop

printer = RubyProf::CallTreePrinter.new(result)

printer.print(path: './reports/calltree', profile: 'callgrind')
