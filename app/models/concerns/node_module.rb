module NodeModule #Attaches to Neo4j Node models.
  extend ActiveSupport::Concern

  included do
    include Neo4j::ActiveNode
    include Neo4j::Timestamps

    self.mapped_label_name = name.remove('Neo::')

    id_property :uuid

    property :name

    unless ["Neo::Season","Neo::Tag"].include?(self.name)
      property :references
      serialize :references
    end

    unless ["Neo::Event","Neo::Tag"].include?(self.name)
      property :image_id
      property :image_path
      property :image_height
      property :image_width
    end
  end

  #Instance Methods
  def sql_model
    self.class.name.remove("Neo::").constantize
  end

  def sql_record
    sql_model.find_by_id(uuid)
  end


end

