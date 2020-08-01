require "ruby-prof"
require_relative "task-1.rb"

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data3250940.txt", true)
end
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby-prof-reports/flat_3_250_940_rows_step_10.2.txt", "w+"))
