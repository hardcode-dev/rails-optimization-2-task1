# frozen_string_literal: true

require_relative 'task-1'

ROWS_COUNT = 100000
FILENAME = "data#{ROWS_COUNT}.txt"

`head -n #{ROWS_COUNT} data_large.txt > #{FILENAME}`

time = Time.now

work(filename: FILENAME, gc: true)

puts Time.now - time

`rm #{FILENAME}`
