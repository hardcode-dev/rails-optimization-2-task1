require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

RubyProf.start

work(ENV['FILENAME'] || 'data.txt')

result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)

printer.print(STDOUT)
printer.print(File.open('./reports/flat/flat_printer_before_5.html', 'w+'))
