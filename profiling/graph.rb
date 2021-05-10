# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

file_path = '../tmp_data/data_100000.txt'
result = RubyProf.profile do
  work(file_path, disable_gc: true)
end
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("../reports/prof_graph_#{file_path.split('_').last.split('.').first}.html", 'w+'))

