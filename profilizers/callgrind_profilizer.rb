# RubyProf CallGrind report
# ruby 15-ruby-prof-callgrind.rb
# brew install qcachegrind
# qcachegrind ruby_prof_reports/...
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(rows_count: 1000)
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => "profilizers/ruby_prof_reports", :profile => 'callgrind')