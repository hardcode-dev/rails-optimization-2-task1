# Deoptimized version of homework task
require 'ruby-prof'
require 'stackprof'
require_relative 'main'

result = RubyProf.profile do
  work('data300000.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph_report.html','w+'))

