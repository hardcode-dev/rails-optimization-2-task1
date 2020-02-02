require_relative './helper'

StackProf.run(mode: :wall, out: "stackprof_reports/task1/stackprof#{Time.now.to_i}.dump", interval: 1000) do
  Optimization::TaskOne.work("#{@root}data/dataN.txt", true)
end
