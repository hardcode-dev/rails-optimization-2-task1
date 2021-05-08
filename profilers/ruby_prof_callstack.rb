require 'ruby-prof'
require_relative '../src/report'

LINES_COUNT = 16_000

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  # work('../data_large.txt', LINES_COUNT)
  work('../data_16000.txt')
end
GC.enable

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('../reports/callstack.html', 'w+'))
