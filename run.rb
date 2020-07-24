require_relative 'lib/worker'

file_name = ARGV[0] || './data/data_x1.txt'
if File.exist?(file_name)
  worker = Worker.new(file_name)
  worker.run
else
  puts 'ФАЙЛ НЕ НАЙДЕН!'
end

