require 'benchmark/ips'

SIZE = 100_000
def w_while
    a = []
    i = 0
    while i <= SIZE
        i += 1
        a << 1
    end
end

def w_loop
    a = []
    i = 0
    loop do
        break if i == SIZE
        i += 1
        a << 1
    end
end

Benchmark.ips do |x|
    x.config(stats: :bootstrap, confidence: 99)

    x.report("while") { w_while }
    x.report("loop") { w_loop }
    x.compare!
end

# shuffle >> sort_by {Random.rand}
# sample >> shuffle.first
# detect >> select.first
# flat_map >> map.flatten
# hash >> ostruct
# start_with? end_with? >> regex
# splatting args is slower than regular args


# while vs loop (>>)
# range#cover? >> range#include?
# date.parse is slow

# Set is fast
# Array#bsearch is fast
#бинарный поиск по отсортированному массиву( сортировать массив и запускать по нему бинарный поиск в первую очередь)
#бинарный поиск – это как детская загадка – за сколько попыток угадаешь число

# медленные исключения – нужно отказываться от них
