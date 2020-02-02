require 'ruby-prof'
require_relative '../../lib/task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Optimization::TaskOne.work("#{@root}data/dataN.txt", true)
end

file_name = "ruby_prof_reports/task1/flat_#{Time.now.to_i}.txt"

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open(file_name, 'w+'))
