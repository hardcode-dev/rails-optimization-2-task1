require 'stackprof'
require_relative 'task-1-improved'

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  ReportGenerator.new.work(input: 'data_80000.txt', output: 'result_benchmark.json', disable_gc: true)
end