# frozen_string_literal: true

require 'benchmark'
require_relative 'task_1'
GC.disable

times = {}

Dir['data_samples/*.txt'].sort.each do |data_sample|
  file_name = data_sample.split('/').last
  p "String process: #{file_name}"

  time = Benchmark.realtime do
    work(file: data_sample)
  end

  times[file_name] = time
end

File.open("reports/time_report_#{Time.now}.txt", 'w+') do |file|
  times.each { |file_name, time| file.write("File: #{file_name} / Time: #{time.round(2)}\n") }
end
