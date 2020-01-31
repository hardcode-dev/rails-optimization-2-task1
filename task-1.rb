# Deoptimized version of homework task
require 'ruby-prof'
require 'stackprof'
require_relative 'main'

result = RubyProf.profile do
  work('data_large.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph_report.html','w+'))

# work('data_large.txt')
