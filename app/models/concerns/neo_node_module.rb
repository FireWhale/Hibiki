module NeoNodeModule
  extend ActiveSupport::Concern

  included do
    after_save :neo_save
  end

  #Instance Methods
  def node_model
    "Neo#{self.class.name}".constantize
  end

  def node_record
    record = node_model.find_by(uuid: self.id)
    record = node_model.new(create_neo_attributes) if record.nil?
    return record
  end

  private
    def neo_save
      node_record.update_attributes(create_neo_attributes)
    end

    def create_neo_attributes
      attributes = {uuid: self.id,
                    name: self.read_name.first,
                    references: self.references.map { |ref| ref.url }}
      return attributes
    end

end

