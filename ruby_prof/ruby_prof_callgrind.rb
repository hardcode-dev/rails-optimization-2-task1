# kcachegrind ruby_prof/reports/callgrind.callgrind.out

require_relative 'prof_config'

result = RubyProf.profile do
  work(file_path: DATA_FILE)
end
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: REPORTS_DIR, profile: 'callgrind')
