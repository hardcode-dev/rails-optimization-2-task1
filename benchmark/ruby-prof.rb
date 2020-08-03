# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('tmp/data_160000.txt', disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('tmp/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('tmp/graph.html', 'w+'))
# `open tmp/graph.html`

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('tmp/callstack.html', 'w+'))
# `open tmp/callstack.html`

# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'tmp', profile: 'callgrind')
# brew install qcachegrind
# qcachegrind tmp/callgrind
