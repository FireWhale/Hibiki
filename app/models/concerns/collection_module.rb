module CollectionModule
  extend ActiveSupport::Concern
  
  included do
    has_many :collections, dependent: :destroy, as: :collected
    has_many :collectors, through: :collections, source: :user

    
    scope :in_collection, ->(userids, *relationships) {first_pass = joins(:collections).where("collections.user_id IN (?)", userids).uniq unless userids.nil?
                                                       relationships.empty? || relationships == [nil] ? first_pass : first_pass.where("collections.relationship IN (?)", relationships.flatten) unless userids.nil?}
    scope :not_in_collection, ->(user_ids, relationships = Collection::Relationship) {joins("LEFT OUTER JOIN(#{Collection.where("collections.user_id IN (?)", user_ids).where(:collected_type => self.to_s).where("collections.relationship IN (?)", relationships).to_sql}) c1 ON c1.collected_id = #{self.table_name}.id").where(:c1 => {:id => nil}) unless user_ids.nil?}
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
