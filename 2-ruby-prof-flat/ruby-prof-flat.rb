# RubyProf Flat report
# ruby ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('../data_assimpt.txt')
end
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby-prof-flat.txt", "w+"))