module NeoNodeModule
  extend ActiveSupport::Concern

  included do
    after_commit :neo_update
  end

  #Instance Methods

  def neo_model
    "Neo::#{self.class.name}".constantize
  end

  def neo_db_record
    neo_model.find_by(uuid: self.id)
  end

  def neo_record
    record = neo_db_record
    record = neo_model.new(neo_properties) if record.nil?
    return record
  end


  private
    def neo_update
      neo_record.update_attributes(neo_properties)
    end

    def neo_properties
      attributes = {uuid: self.id}
      if self.respond_to?(:read_name)
        attributes[:name] = self.read_name
      else
        attributes[:name] = self.name
      end
      attributes[:references] = self.references.map { |ref| ref.url } if self.respond_to?(:references)
      attributes[:image_id] = self.primary_images.first.id if self.respond_to?(:images) && self.primary_images.blank? == false
      return attributes
    end


end

