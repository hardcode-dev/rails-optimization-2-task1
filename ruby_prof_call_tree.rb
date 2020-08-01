require "ruby-prof"
require_relative "task-1.rb"

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data120000.txt", disable_gc: true)
end
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: "ruby-prof-reports", profile: "callgrind_120_000_rows_step_5.1")
