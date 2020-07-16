# frozen_string_literal: true

Dir.mkdir('tmp') unless Dir.exist?('tmp')

`rm tmp/data_*.txt`
`gunzip -c data_large.txt.gz > tmp/data_large.txt`

range = [10_000, 20_000, 40_000, 80_000, 160_000]

range.each do |n|
  `head -n #{n} tmp/data_large.txt > tmp/data_#{n}.txt`
end
