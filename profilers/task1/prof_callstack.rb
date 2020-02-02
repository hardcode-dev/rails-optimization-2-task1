require_relative './helper'

result = RubyProf.profile do
  Optimization::TaskOne.work("#{@root}data/dataN.txt", true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby_prof_reports/task1/callstack_#{Time.now.to_i}.html", 'w+'))
