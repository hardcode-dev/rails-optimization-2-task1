require 'benchmark'

TIMES = 10000
concat_arrays = []
add_item = []
Benchmark.bmbm(10) do |b|
  b.report('concat_arrays') { TIMES.times { concat_arrays = concat_arrays + [nil] } }
  b.report('add_item') { TIMES.times { add_item << [nil] } }
end
