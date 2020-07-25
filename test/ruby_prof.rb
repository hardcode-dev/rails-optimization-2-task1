require 'ruby-prof'
require 'stringio'
require_relative '../lib/worker'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  worker = Worker.new("#{__dir__}/../data/data4.txt")
  worker.run
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/ruby-prof-graph.html", 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/ruby-prof-callstack.html", 'w+'))
