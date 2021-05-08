require 'stackprof'
require_relative '../src/report'

LINES_COUNT = 16_000

GC.disable
profile = StackProf.run(mode: :wall, raw: true) do
  # work('../data_large.txt', LINES_COUNT)
  work('../data_16000.txt')
end

File.write('../reports/stackprof.json', JSON.generate(profile))

GC.enable
