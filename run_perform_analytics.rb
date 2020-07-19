# frozen_string_literal: true

require 'benchmark'
require 'stackprof'
require 'ruby-prof'

require_relative 'task_1'

GC.disable

# Analitics by RubyProf::CallStackPrinter
result = RubyProf.profile do
  work(file: 'data_samples/data_80-000.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("reports/ruby_prof_call_stack_#{Time.now}.html", 'w+'))

# Analitics by Stack Prof
StackProf.run(mode: :wall, out: "reports/stackprof_#{Time.now}.dump", interval: 1000) do
  work(file: 'data_samples/data_20-000.txt')
end
