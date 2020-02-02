require 'ruby-prof'
require_relative '../task-1-optim.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

filename = 'data_1_000_000.txt'

result = RubyProf.profile do
  work(filename, disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("profilers/ruby_prof_reports/callstack_#{filename}.html", 'w+'))
