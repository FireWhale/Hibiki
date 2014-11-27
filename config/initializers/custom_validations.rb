# Be sure to restart your server when you modify this file.

ActiveRecord::Base.class_eval do
  def self.validates_unique_combination(*attr_names)
    options = attr_names.extract_options!
    validates_each(attr_names, options) do |record, attribute|
      matches = record.class.where(
      (options[:model] + '1_id').to_sym => [record.send(options[:model] + '1_id'), record.send(options[:model] + '2_id')], 
      (options[:model] + '2_id').to_sym => [record.send(options[:model] + '1_id'), record.send(options[:model] + '2_id')])
      if matches.empty? == false && matches.map(&:id).include?(record.id) == false
        record.errors.add(:base, 'Duplicate #{options[:model]} combination') 
      end
    end
  end
  
  def self.validates_different_models(*attr_names)
    options = attr_names.extract_options!
    validates_each(attr_names, options) do |record, attribute|
      record.errors.add(:base, 'Same #{options[:model]} in both associations!') if record.send(options[:model] + '1') == record.send(options[:model] + '2')
    end      
  end
end
