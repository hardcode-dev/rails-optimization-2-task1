require "json"
require "benchmark"
require "pp"

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def measure(&block)
  puts "rss before array allocation: #{print_memory_usage}"
  no_gc = (ARGV[0] == "--no-gc")
  if no_gc
    GC.disable
  else
    # collect memory allocated during library loading # and our own code before the measurement
    GC.start
  end
  memory_before = "ps -o rss= -p #{Process.pid}".to_i / 1024
  gc_stat_before = GC.stat
  time = Benchmark.realtime do
    yield
  end
  pp ObjectSpace.count_objects

  # unless no_gc
  #   GC.start(full_mark: true, immediate_sweep: true, immediate_mark: false)
  # end
  # pp ObjectSpace.count_objects
  gc_stat_after = GC.stat
  memory_after = "ps -o rss= -p #{Process.pid}".to_i / 1024
  puts({
    RUBY_VERSION => {
      gc: no_gc ? "disabled" : "enabled",
      time: time.round(2),
      gc_count: gc_stat_after[:count] - gc_stat_before[:count], memory: "%d MB" % (memory_after - memory_before),
    },
  }.to_json)
  puts "rss after concatenation: #{print_memory_usage}"
end
