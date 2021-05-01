require_relative 'task-1'
#require_relative 'task-origin'
require 'ruby-prof'
require 'stackprof'


p "Start prof..."
n = 250000
ProgressBarEnabler.enable!
GC.disable
ProgressBarEnabler.disable!
RubyProf.measure_mode = RubyProf::WALL_TIME
result = RubyProf.profile do
  work("data/data#{n}.txt")
  #work('data/data_large.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('prof_reports/graph.html', 'w+'))

#FLAT PROF
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('prof_reports/flat.txt', 'w+'))

#TREE PROF
#qcachegrind prof_reports/callgrind.callgrind.out.68945
printer = RubyProf::CallTreePrinter.new(result)
printer.print(:path => "prof_reports", :profile => 'callgrind')

#CALLSTACK
printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('prof_reports/callstack.html', 'w+'))


#system("open", "http://localhost:8000/flat.txt")
system("open", "http://localhost:8000/callstack.html")
system("open", "http://localhost:8000/graph.html")


# Stackprof report -> flamegraph in speedscope https://www.speedscope.app
puts "Start stackproof..."
profile = StackProf.run(mode: :wall, raw: true, ignore_gc: true) do
  work("data/data#{n}.txt")
  #work('data/data_large.txt')
end
File.write("stackprof_reports/stackprof_#{Time.now.to_i.to_s}.json", JSON.generate(profile))


# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
#StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof_gc.dump', interval: 1000, ignore_gc: true) do
#  work("data/data#{n}.txt")
#end