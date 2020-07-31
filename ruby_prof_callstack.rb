require 'ruby-prof'
require_relative 'task-1-improved'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  ReportGenerator.new.work(input: 'data_160000.txt', output: 'result_benchmark.json', disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby_prof_reports/ruby_prof_callstack.html", "w+"))