# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME
DEMO_DATA = Dir['analyzers/demo_data/*.txt'].freeze

GC.disable

DEMO_DATA.each do |data_path|
  result = RubyProf.profile do
    work(data_path)
  end
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(File.open("analyzers/reports/ruby_prof_flat_#{data_path.split('_').last}", 'w+'))
end
