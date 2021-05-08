require 'stackprof'
require_relative '../src/report'

LINES_COUNT = 16_000

GC.disable
StackProf.run(mode: :wall, out: '../reports/stackprof.dump', interval: 1000) do
  # work('../data_large.txt', LINES_COUNT)
  work('../data_16000.txt')
end
GC.enable
