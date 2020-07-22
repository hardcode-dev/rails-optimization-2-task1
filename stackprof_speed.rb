require 'stackprof'
require_relative 'task-1'

GC.disable

profile = StackProf.run(mode: :wall, raw: true) do
  work(file_path: 'data_samples/test_data.txt')
end

File.write('reports/stackprof.json', JSON.generate(profile))
