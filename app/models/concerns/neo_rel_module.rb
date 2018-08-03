module NeoRelModule
  extend ActiveSupport::Concern

  included do
    after_save :neo_save
  end

  #Instance Methods
  def rel_model
    "Neo#{self.class.name}".constantize
  end

  def rel_record
    node_model.where(uuid: self.id)
  end

  private
    def neo_save
      rel_model.create(uuid: self.id, name: self.read_name.first)
    end


end

