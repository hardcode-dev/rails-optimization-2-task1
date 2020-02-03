# gem install kalibera
require 'benchmark/ips'

# SIZE = 100_000

# def work_with_while
#   a = []
#   i = 0
#   while i <= SIZE
#     i += 1
#     a << i
#   end
# end

# def work_with_loop
#   a = []
#   i = 0
#   loop do
#     break if i == SIZE
#     i += 1
#     a << i
#   end
# end

# Benchmark.ips do |x|
#   # The default is :stats => :sd, which doesn't have a configurable confidence
#   # confidence is 95% by default, so it can be omitted
#   x.config(:stats => :bootstrap, :confidence => 99)

#   x.report("while") { work_with_while }
#   x.report("loop") { work_with_loop }
#   x.compare!
# end

def iterate_array(array)
  array.each { |i| }
end

def iterate_hash(hash)
  hash.each { |i| }
end

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(:stats => :bootstrap, :confidence => 99)

  array_1000 = (1..1000).to_a
  hash_1000 = Hash[*(1..2000).to_a]

  x.report('generate_array from 1000 rows') { iterate_array(array_1000) }
  x.report('generate hash from 1000 rows') { iterate_hash(hash_1000) }
  x.compare!
end



def create_array(size)
  Array.new(size){ |index| [0, 0, 0, [], nil, nil, []] }

  # {
  #   sessionsCount: 0,
  #   totalTime: 0,
  #   longestSession: 0,
  #   browsers: [],
  #   usedIE: false,
  #   alwaysUsedChrome: true,
  #   dates: []
  # }
end


Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(:stats => :bootstrap, :confidence => 99)

  SIZE = [10, 100, 1000, 10_000, 100_000, 1000_000]

  SIZE.each { |size| x.report("create array with #{size} users") { create_array(size) } }
  x.compare!
end