require_relative 'prof_config'

result = RubyProf.profile do
  work(file_path: DATA_FILE)
end
printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open(REPORTS_DIR + 'call_stack2.html', 'w+'))
