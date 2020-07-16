.PHONY: test

all: samples test bench
samples:
	ruby benchmark/data_samples.rb
test:
	ruby test/task_1_test.rb
	rspec test/performance_spec.rb
bench:
	ruby benchmark/benchmark_realtime.rb
	ruby benchmark/ruby-prof.rb
