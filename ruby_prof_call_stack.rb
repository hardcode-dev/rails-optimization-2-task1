require "ruby-prof"
require_relative "task-1.rb"

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data3250940.txt", true)
end
printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby-prof-reports/callstack_3_250_940_rows_step_10.2.html", "w+"))
