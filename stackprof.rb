require 'stackprof'
require_relative 'task-1.rb'

GC.disable

StackProf.run(mode: :wall, out: 'reports/stackprof.dump', interval: 1000) do
  work('samples/16000.txt')
end

# require 'json'
#
# profile = StackProf.run(mode: :wall, raw: true) do
#   work('samples/1000.txt')
# end
#
# File.write('reports/stackprof.json', JSON.generate(profile))