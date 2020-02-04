require 'benchmark'
require_relative '../../task-1.rb'

SAMPLE_FILES = Dir['small_samples/*'].sort_by { |name| name[/\d+/].to_i }

Benchmark.bm do |x|
  SAMPLE_FILES.each do |f|
    x.report(f) do
      work(f)
    end
  end
end
