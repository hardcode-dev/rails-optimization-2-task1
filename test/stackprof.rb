require 'stackprof'
require_relative '../lib/worker'

GC.disable

StackProf.run(mode: :wall, out: File.open("#{__dir__}/../tmp/stackprof.dump", 'w+')) do
  worker = Worker.new("#{__dir__}/../data/data4.txt")
  worker.run
end
