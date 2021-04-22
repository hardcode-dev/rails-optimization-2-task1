# frozen_string_literal: true

FILE_NAME_LARGE = 'data_large.txt'
REPORT_PATH = './report'
LIMIT = 10_000
NO_LIMIT = nil

OPEN_CMD = RUBY_PLATFORM =~ /darwin/ ? 'open' : 'xdg-open'

require 'benchmark'
require 'ruby-prof'
require 'stackprof'

require './src/work.rb'

LIMITS = [
  0,
  100, 200, 500,
  1_000, 2_000, 5_000,
  10_000, 20_000, 50_000,
  100_000, 200_000
]

def do_work(limit: LIMIT, gc: nil, progress_bar: nil)
  gc_disabled = GC.disable unless gc
  work(limit: limit, file_name: FILE_NAME_LARGE, progress_bar: progress_bar)
  GC.enable if gc_disabled
end

def benchmark_on_limit
  res = []
  LIMITS.each do |limit|
    res.push "| #{limit} | #{Benchmark.measure { do_work limit: limit, gc: true }.to_s.chop} |"
  end
  res.join("\n")
end

def profile_using_ruby_prof(printer_class, report: nil, profile: nil)
  RubyProf.measure_mode = RubyProf::WALL_TIME
  res = RubyProf.profile { do_work }
  printer = printer_class.new(res)
  report_file_name = "#{REPORT_PATH}/#{report}"
  if profile
    printer.print report: REPORT_PATH, profile: profile
    `qcachegrind #{REPORT_PATH}`
  else
    printer.print File.open(report_file_name, 'w')
    `#{OPEN_CMD} #{report_file_name}`
  end
end

def profile_flat
  profile_using_ruby_prof RubyProf::FlatPrinter, report: 'flat.txt'
end

def profile_graph
  profile_using_ruby_prof RubyProf::GraphHtmlPrinter, report: 'graph.html'
end

def profile_callstack
  profile_using_ruby_prof RubyProf::CallStackPrinter, report: 'callstack.html'
end

def profile_calltree
  profile_using_ruby_prof RubyProf::CallTreePrinter, profile: 'callgrind'
end

def profile_stackprof
  StackProf.run(mode: :wall, out: "#{REPORT_PATH}/stackprof.dump", interval: 1000) do
    do_work
  end
end

def profile_stackprof_json
  profile = StackProf.run(mode: :wall, raw: true, interval: 1000) do
    do_work
  end

  File.write("#{REPORT_PATH}/stackprof.json", JSON.generate(profile))
end

def benchmark
  Benchmark.benchmark('', 4, nil, 'AVG:') do |bm|
    res = 10.times.map { |ix| bm.report(ix) { do_work } }
    [res.reduce(:+) / res.size]
  end
end

# puts Benchmark.measure { do_work(limit: NO_LIMIT, progress_bar: true) }

benchmark

# puts "-" * 99
# puts benchmark_on_limit
# puts "=" * 99

# profile_flat
# profile_graph
# profile_callstack
# profile_calltree

# profile_stackprof
# profile_stackprof_json