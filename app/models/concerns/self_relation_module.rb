module SelfRelationModule
  extend ActiveSupport::Concern
  
  included do
    model_string = self.model_name.singular
    
    #Associations
      has_many "related_#{model_string}_relations1".to_sym,
               class_name: "Related#{model_string.capitalize}s",
               foreign_key: "#{model_string}1_id", dependent: :destroy
      has_many "related_#{model_string}_relations2".to_sym,
               class_name: "Related#{model_string.capitalize}s",
               foreign_key: "#{model_string}2_id", dependent: :destroy
      has_many "related_#{model_string}s1".to_sym,
               through: "related_#{model_string}_relations1".to_sym,
               source: "#{model_string}2"
      has_many "related_#{model_string}s2".to_sym,
               through: "related_#{model_string}_relations2".to_sym,
               source: "#{model_string}1"
        
    
    #Scope
      scope :with_self_relation_categories, ->(categories) {joins("related_#{model_string}_relations1".to_sym).where("related_#{model_string}s.category IN (?)", categories).uniq unless categories.nil?}
      scope :without_self_relation_categories, ->(categories = "Related#{model_string.capitalize}s".constantize::Relationships){joins("LEFT OUTER JOIN (#{"Related#{model_string.capitalize}s".constantize.where("related_#{model_string}s.category IN (?)", categories).to_sql}) t1 ON t1.#{model_string}1_id = #{model_string}s.id").where(:t1 => {:id => nil})}      

    #Class methods - uses singleton method to use the model_string
      define_method "related_#{model_string}_relations" do
        "Related#{model_string.capitalize}s".constantize.from("((#{self.send("related_#{model_string}_relations1").to_sql}) union (#{self.send("related_#{model_string}_relations2").to_sql})) as related_#{model_string}s")
      end
      
      define_method "related_#{model_string}s" do
        model_string.capitalize.constantize.from("((#{self.send("related_#{model_string}s1").to_sql}) union (#{self.send("related_#{model_string}s2").to_sql})) as #{model_string}s") 
      end
  end  
  
end
