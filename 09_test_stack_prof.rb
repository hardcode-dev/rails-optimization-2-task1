require 'stackprof'
require_relative 'task-1'

StackProf.run(mode: :wall, out: 'stack_prof_report/report.dump', interval: 1000) do
  work
end
