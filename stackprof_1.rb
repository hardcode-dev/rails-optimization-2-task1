require "stackprof"
require_relative "task-1.rb"


StackProf.run(mode: :wall, out: 'stackprof-reports/stackprof.dump', interval: 1000) do
  work("data325000.txt", disable_gc: true)
end
