require_relative 'lib/worker'

file_name = ARGV[0] || './data/data1.txt'
if File.exist?(file_name)
  worker = Worker.new(file_name, true)
  worker.run
else
  puts 'ФАЙЛ НЕ НАЙДЕН!'
end

