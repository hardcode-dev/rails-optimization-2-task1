# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_100000.txt', disable_gc: true)
end

Dir.chdir(File.dirname(__FILE__))

RubyProf::FlatPrinter.new(result).print(File.open('reports/flat.txt', 'w+'))

RubyProf::GraphHtmlPrinter.new(result).print(File.open('reports/graph.html', 'w+'))

RubyProf::CallStackPrinter.new(result).print(File.open('reports/callstack.html', 'w+'))

RubyProf::CallTreePrinter.new(result).print(path: 'reports', profile: 'callgrind')
