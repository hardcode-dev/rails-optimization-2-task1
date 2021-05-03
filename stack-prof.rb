require 'stackprof'
require 'json'
require_relative './task-1'

# StackProf.run(mode: :wall, out: 'stack_prof/stackprof.dump', interval: 1000) do
#   work(file: "data100000.txt", disable_gc: true)
# end

profile = StackProf.run(mode: :wall, raw: true) do
  work(file: 'data100000.txt', disable_gc: true)
end
File.write('stack_prof/stackprof.json', JSON.generate(profile))
