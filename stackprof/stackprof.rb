# frozen_string_literal: true

require 'stackprof'
require_relative '../task-1.rb'

result = StackProf.run(mode: :wall, raw: true) do
  work('data_10000.txt', disable_gc: true)
end

Dir.chdir(File.dirname(__FILE__))

File.write('reports/stackprof.json', JSON.generate(result))
