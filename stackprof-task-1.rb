# Stackprof report
# ruby 16-stackprof.rb
# cd stackprof_reports
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require 'stackprof'
require_relative 'work_method.rb'

StackProf.run(mode: :wall, out: 'ruby_prof_reports/stackprof.dump', interval: 1000) do
  work('data_small.txt', disable_gc: true)
end
