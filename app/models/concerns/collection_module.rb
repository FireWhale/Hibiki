module CollectionModule
  extend ActiveSupport::Concern
  
  included do
    has_many :collections, dependent: :destroy, as: :collected
    has_many :collectors, through: :collections, source: :user

    scope :in_collection, ->(userids, *relationships) {joins(:collections).where("collections.user_id IN (?) AND collections.relationship IN (?)", userids, relationships.empty? || relationships == [nil] ? Collection::Relationship : relationships.flatten & Collection::Relationship).distinct unless userids.nil?}

    scope :not_in_collection, ->(userids, *relationships) {joins("LEFT OUTER JOIN(#{Collection.where("collections.user_id IN (?) AND collections.relationship IN (?)", userids, relationships.empty? || relationships == [nil] ? Collection::Relationship : relationships.flatten & Collection::Relationship).to_sql}) c1 ON c1.collected_id = #{self.table_name}.id").where(:c1 => {:id => nil}) unless userids.nil?}
  end
  
  def collected?(user)
    self.collections.select {|a| a.user_id == user.id}.empty? == false    
  end 
  
  def collected_category(user)
    #returns the type of collection relationship 
    #if not in collection, returns "" (empty)
    if user.nil? || self.collections.select { |a| a.user_id == user.id}.empty?
      ""
    else
      self.collections.select { |a| a.user_id == user.id}[0].relationship
    end
  end         
end
