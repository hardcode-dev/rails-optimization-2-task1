require 'ruby-prof'
require_relative '../src/report'

LINES_COUNT = 16_000

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  work('../data_large.txt', LINES_COUNT)
end
GC.enable

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: '../reports', profile: 'callgrind')
