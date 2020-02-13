require 'stackprof'
require 'json'

require_relative 'task-1'

system('mkdir -p reports')

StackProf.run(mode: :wall, out: 'reports/stackprof-wall-task-1.dump') do
  work('data_30000.txt')
end

profile = StackProf.run(mode: :wall, raw: true) do
  work('data_30000.txt')
end

File.write('reports/stackprof-wall-task-1.json', JSON.generate(profile))
