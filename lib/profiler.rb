# frozen_string_literal: true

require 'stackprof'
require 'ruby-prof'
require_relative '../task-1'

# stackprof stackprof_reports/stackprof.dump

test_path_10k = 'files/data-10k'
# test_path_20k = 'files/data-20k'
# test_path_100k = 'files/data-100k'
# test_path_300k = 'files/data-300k'

GC.disable

# StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
#   work(test_path_10k)
# end

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(test_path_10k)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
