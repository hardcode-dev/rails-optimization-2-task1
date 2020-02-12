require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_large.txt', disable_gc: true)
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => "ruby_prof_reports", :profile => 'callgrind')
