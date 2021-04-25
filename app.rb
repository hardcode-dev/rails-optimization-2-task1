require_relative 'task-1'

require 'benchmark'
require 'benchmark/ips'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME


GC.disable
result = RubyProf.profile do
  work('data10000.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports_graph.html", "w+"))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports_callstack.html', 'w+'))
puts "Finish profile"

GC.enable
# Benchmark.ips do |x|
#   x.config(
#     stats: :bootstrap,
#     confidence: 95
#   )
#
#   x.report("parse sessions") do
#     work('data1000.txt')
#   end
# end

time = Benchmark.realtime do
  work('data10000.txt')
end

puts "Finish 10000 in #{time.round(2)}"

time = Benchmark.realtime do
  work('data100000.txt')
end
puts "Finish 100_000 in #{time.round(2)}"

time = Benchmark.realtime do
  work('data1000000.txt')
end
puts "Finish 1_000_000 in #{time.round(2)}"

time = Benchmark.realtime do
  work('data_large.txt')
end
puts "Finish large in #{time.round(2)}"

