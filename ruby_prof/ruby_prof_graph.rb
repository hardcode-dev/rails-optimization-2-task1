require_relative 'prof_config'

result = RubyProf.profile do
  work(file_path: DATA_FILE)
end
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open(REPORTS_DIR + 'graph2.html', 'w+'))
