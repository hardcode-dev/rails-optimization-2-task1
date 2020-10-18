require 'benchmark'
require 'ruby-prof'

require_relative 'task-1'


class Playground
  def call
    puts "### Playground start"

    simple_time_measurement
    # ruby_prof_flat
    # ruby_prof_graph
    # ruby_prof_callstack
    # asymptomatic_stats
  end

  private

  def ruby_prof_callstack
    result = ruby_prof_result
    printer = RubyProf::CallStackPrinter.new(result)
    printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
    puts "CallStack Generated"
  end

  def ruby_prof_graph
    result = ruby_prof_result
    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(File.open("ruby_prof_reports/graph.html", "w+"))
    puts "Graph Report Generated"
  end

  def ruby_prof_flat
    result = ruby_prof_result
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))
    puts "Flat Report Generated."
  end

  def ruby_prof_result
    rprof_result = RubyProf.profile do
      Report.new.call
    end
    rprof_result
  end


  def asymptomatic_stats
    Benchmark.ips do |generate_report|
      generate_report.report('lines8000') {Report.new.call('data_8000.txt')}
      generate_report.report('lines16000') {Report.new.call('data_16000.txt')}
      generate_report.report('lines32000') {Report.new.call('data_32000.txt')}
      generate_report.report('lines64000') {Report.new.call('data_64000.txt')}
      generate_report.compare!
    end
  end

  def simple_time_measurement
    time = Benchmark.realtime do
      # Report.new.call
      Report.new.call('data_large.txt')
    end

    puts "Report finished in #{time.round(3)} seconds"
  end
end

Playground.new.call