# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  work('analyzers/demo_data/data_large.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'analyzers/reports/', profile: 'callgrind')
