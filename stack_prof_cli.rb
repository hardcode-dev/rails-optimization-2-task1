require 'stackprof'
require_relative 'task-1.rb'

StackProf.run(mode: :wall, out: 'stack_prof_reports/stack_prof.dump', interval: 1000) do
  Work.new.work('data10000.txt', disable_gc: true)
end
