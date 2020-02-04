# frozen_string_literal: true

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode == RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work('data_test.txt')
  GC.enable
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))
