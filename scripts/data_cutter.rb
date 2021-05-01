min_size = size = 10000
multi = 2
while size <= 100_000 do
    system("cd data && head -n #{size} data_large.txt > data#{size}.txt")
    size = size + min_size
end