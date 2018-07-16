module DateModule
  extend ActiveSupport::Concern

  included do

    self.attribute_names.select { |n| self.attribute_names.include?("#{n}_bitmask")}.each do |date_name|
      define_method "#{date_name}_formatted" do
        if self.send("#{date_name}_bitmask") == 6 #Missing Day, Month
          self.send(date_name).year.to_s
        elsif self.send("#{date_name}_bitmask") == 4 #Missing Day
          self.send(date_name).to_formatted_s(:month_and_year)
        elsif self.send("#{date_name}_bitmask") == 1 #Missing Year
          self.send(date_name).to_formatted_s(:month_and_day)
        elsif self.send("#{date_name}_bitmask") == 7 #Missing all 3
          nil
        else
          self.send(date_name).to_formatted_s(:long)
        end
      end
    end

  end

end
