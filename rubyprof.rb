require 'ruby-prof'
require_relative 'task-1.rb'

GC.disable
RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('samples/16000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(:path => "reports", :profile => 'callgrind')