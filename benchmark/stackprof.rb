require 'stackprof'
require_relative '../task-1'

profile = StackProf.run(mode: :wall, raw: true) do
  work(file_name: './tmp/data_100000.txt', disable_gc: true)
end

system('rm -rf reports/stackprof')
system('mkdir -p reports/stackprof')

File.write('reports/stackprof/stackprof.json', JSON.generate(profile))
