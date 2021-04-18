# Stackprof report
# ruby ruby-stack-prof.rb
# cd 6-ruby-stackprof
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require 'stackprof'
require_relative '../task-1.rb'

StackProf.run(mode: :wall, out: 'stackprof.dump', interval: 1000) do
  work('../data_large.txt')
end