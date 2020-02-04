users_count = 0
SAMPLE_SIZES = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]

File.open('../../data_large.txt') do |f|
  SAMPLE_SIZES.each do |sample_size|
    sample_file = File.open("small_samples/data_#{sample_size}.txt", 'w')
    f.each_line do |l|
      if l.start_with? 'user'
        break if users_count >= sample_size
        users_count += 1
      end
      sample_file << l
    end
    f.rewind
    users_count = 0
  end
end
