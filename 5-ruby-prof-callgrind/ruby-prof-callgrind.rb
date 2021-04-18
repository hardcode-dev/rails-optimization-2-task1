# RubyProf CallGrind report
# ruby ruby-prof-callgrind.rb
# brew install qcachegrind
# qcachegrind ruby_prof_reports/...
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('../data_assimpt.txt')
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:profile => 'callgrind')