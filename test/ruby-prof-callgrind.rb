require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('test/support/small_samples/data_2500.txt', disable_gc: true)
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(path: 'test/ruby_prof_reports', profile: 'callgrind')
