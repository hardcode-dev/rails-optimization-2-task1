require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data_large.txt")
end
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby-prof/flat.txt", "w+"))


