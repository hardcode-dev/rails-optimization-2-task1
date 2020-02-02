require 'json'
require 'stackprof'
require_relative '../task-1.rb'

filename = 'data_1_000.txt'

profile = StackProf.run(mode: :wall, raw: true) do
  work(filename, disable_gc: true)
end

File.write("profilers/stackprof_reports/stackprof_#{filename}.json", JSON.generate(profile))
