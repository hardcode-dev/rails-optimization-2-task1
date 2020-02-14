require 'json'
require 'stackprof'
require_relative 'task-1.rb'

profile = StackProf.run(mode: :wall, raw: true) do
  Work.new.work('data10000.txt', disable_gc: true)
end

File.write('stack_prof_reports/stack_prof.json', JSON.generate(profile))
