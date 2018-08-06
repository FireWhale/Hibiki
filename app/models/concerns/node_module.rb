module NodeModule
  extend ActiveSupport::Concern

  included do
    include Neo4j::ActiveNode
    include Neo4j::Timestamps

    id_property :uuid

    property :name

    unless ["Neo::Season","Neo::Tag"].include?(self.name)
      property :references
      serialize :references
    end

    property :image_id unless ["Neo::Event","Neo::Tag"].include?(self.name)
  end

  #Instance Methods
  def sql_model
    self.class.name.remove("Neo::").constantize
  end

  def sql_record
    sql_model.find_by_id(uuid)
  end


end

