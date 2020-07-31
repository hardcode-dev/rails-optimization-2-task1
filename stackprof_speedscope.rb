require 'stackprof'
require_relative 'task-1-improved'


profile = StackProf.run(mode: :wall, raw: true) do
  ReportGenerator.new.work(input: 'data_160000.txt', output: 'result_benchmark.json', disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))