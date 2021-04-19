require 'ruby-prof'
require 'benchmark'
require 'benchmark/ips'
require_relative 'task-1'
require_relative 'optimized'

TIMES = 100

Benchmark.bmbm(10) do |b|
  b.report("work") { Parser.work('data/data_1000.txt') }
  b.report("optimized") { ParserOptimized.work('data/data_1000.txt') }
end

# ips benchmark
# Benchmark.ips(10) do |b|
#   b.report("work") { Parser.work('data/data_1000.txt') }
#   b.report("optimized") { ParserOptimized.work('data/data_1000.txt') }
#
#   b.compare!
# end


# time = Benchmark.realtime do
  # ParserOptimized.work('data_large.txt')
# end

# puts time.to_s

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile(track_allocations: true) do
  ParserOptimized.work('data/data_1000.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby-prof-callstack.html', 'w+'))

exec "open #{File.absolute_path('reports/ruby-prof-callstack.html')}"
