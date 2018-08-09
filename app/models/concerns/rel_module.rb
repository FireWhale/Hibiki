module RelModule #attached to Neo4j Relationship Models
  extend ActiveSupport::Concern

  included do
    include Neo4j::ActiveRel
    include Neo4j::Timestamps

    property :uuid

  end

  #Instance Methods
  def sql_model
    if self.class == Neo::RelatedRecord
      "Related#{self.from_node.class.name.remove("Neo::")}s".constantize unless self.from_node.blank?
    else
      self.class.name.remove("Neo::").constantize
    end
  end

  def sql_record
    sql_model.find_by_id(uuid) unless sql_model.blank?
  end

end