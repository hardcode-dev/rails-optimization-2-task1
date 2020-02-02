require 'json'
require 'stackprof'
require_relative '../../lib/task-1'

profile = StackProf.run(mode: :wall, raw: true) do
  Optimization::TaskOne.work("#{@root}data/dataN.txt", true)
end

File.write("stackprof_reports/task1/stackprof#{Time.now.to_i}.json", JSON.generate(profile))
