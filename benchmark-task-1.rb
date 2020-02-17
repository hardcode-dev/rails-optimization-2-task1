require "./measure.rb"
require_relative "work_method.rb"

# measure do
#   work("data_small.txt", disable_gc: true)
# end

# measure do
#   work_new("data_small.txt", disable_gc: true)
# end

# measure do
#   work("data_large.txt", disable_gc: true)
# end

measure do
  work_new("data_large.txt", disable_gc: true)
end
