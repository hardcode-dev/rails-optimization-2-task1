# frozen_string_literal: true

require_relative 'task-1'
FILENAME = 'data_assimpt.txt'

log = ['Assimptotics results:']

%w[500000 1000000 1500000 2000000 2500000 3000000].each do |num_rows|
  puts "Started #{num_rows}"
  if system("head -n #{num_rows} data_large.txt > #{FILENAME}") && (`wc -l < #{FILENAME}`.strip == num_rows)
    start_time = Time.now.to_i
    work(FILENAME)
    log << "#{num_rows}: #{Time.now.to_i - start_time} sec;"
  end
  File.delete(FILENAME) if File.exist?(FILENAME)
end

puts log
