# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('analyzers/demo_data/data_large.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('analyzers/reports/callstack.html', 'w+'))
