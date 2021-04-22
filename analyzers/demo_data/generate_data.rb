# frozen_string_literal: true

LINE_COUNTS = [10_000, 20_000, 30_000, 100_000].freeze
CURRENT_PATH = __dir__.freeze
DATA_LARGE_PATH = "#{CURRENT_PATH}/data_large.txt"

LINE_COUNTS.each do |count|
  `head -n #{count} #{DATA_LARGE_PATH} > #{CURRENT_PATH}/demo_data_#{count}.txt`
end
