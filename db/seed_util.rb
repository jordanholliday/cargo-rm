require 'CSV'

class SeedUtil
  def self.csv_seed!(klass, csv_path, attr_arr)
    CSV.foreach(csv_path) do |row|
      record = klass.new
      attr_arr.each_with_index do |attribute, idx|
        record.send(attribute + "=", row[idx])
      end
      record.insert
    end
  end
end
