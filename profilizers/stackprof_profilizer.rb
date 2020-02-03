require 'stackprof'
require_relative '../task-1.rb'

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work(rows_count: 1000)
end
