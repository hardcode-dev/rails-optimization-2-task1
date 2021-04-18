# RubyProf CallStack report
# ruby ruby-prof-callstack.rb
# open ruby_prof_reports/callstack.html
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  #work('data_small.txt', disable_gc: true)
  work('../data_assimpt.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('callstack.html', 'w+'))