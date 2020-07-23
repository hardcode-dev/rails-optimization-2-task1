module DataHelper
  def prepare_sample_for_speed_test(lines_count)
    system("head -n #{lines_count} data_files/data_large.txt > data_files/data#{lines_count}.txt")
  end

  def remove_sample_for_speed_test(lines_count)
    File.delete("data_files/data#{lines_count}.txt")
  end
end