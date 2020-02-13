require 'benchmark-trend'
require 'gnuplot'

require_relative 'task-1'
require 'pry'

range =  [500, 1000, 2000, 4000, 8000, 16000]

  system('mkdir test')
  range.each do |n|
    system("head -n #{n} data_large.txt > test/data_#{n}.txt")
  end


trend, trends = Benchmark::Trend.infer_trend(range, repeat: 10) do |n, i|
  work("test/data_#{n}.txt")
end

system('rm test/*')

puts "Trend data:"
pp trends

x_data_set = []
y_data_set = []
(1..3250940).step(1000).each do |n|
  x_data_set << n
  y_data_set << Benchmark::Trend.fit_at(trend, slope: trends[trend][:slope], intercept: trends[trend][:intercept], n: n)
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  
    plot.xrange "[0:#{x_data_set.last}]"
    plot.title  "algorithm work time"
    plot.xlabel "Number of lines"
    plot.ylabel "Time (seconds)"
    
    plot.data << Gnuplot::DataSet.new([x_data_set, y_data_set] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 4
    end
    
  end
  
end

