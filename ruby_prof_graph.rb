require "ruby-prof"
require_relative "task-1.rb"

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data480000.txt", true)
end
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby-prof-reports/graph_480_000_rows_step_7.4.html", "w+"))
