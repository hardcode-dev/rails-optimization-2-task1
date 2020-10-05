# frozen_string_literal: true

class Sample
  ROOT = Pathname(__dir__)

  attr_reader :size, :path

  def initialize(size)
    @path = ROOT / 'samples' / "data_#{size}.txt"

    ensure_exists!(size)

    @size = Integer(size, 10) rescue calculate_size
  end

  private

  def ensure_exists!(size)
    return if path.exist?

    lines = Integer(size, 10)

    File.open(REFERENCE_SAMPLE.path, 'r') do |reference_sample|
      File.open(path, 'w') do |new_sample|
        reference_sample.each_line.take(lines).each do |line|
          new_sample.write(line)
        end
      end
    end
  end

  def calculate_size
    File.open(path, 'r') do |file|
      file.each_line.count
    end
  end

  # Assumed to already be there. Can be created by running
  # unar data_large.txt.gz -o samples
  REFERENCE_SAMPLE = new('large')
  private_constant :REFERENCE_SAMPLE
end
