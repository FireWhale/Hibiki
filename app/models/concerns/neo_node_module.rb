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
    node_model.where(uuid: self.id)
  end

  private
    def neo_save
      node_model.create(uuid: self.id, name: self.read_name.first)
    end


end

