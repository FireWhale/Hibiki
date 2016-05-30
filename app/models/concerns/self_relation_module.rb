module SelfRelationModule
  extend ActiveSupport::Concern

  included do
    model_string = self.model_name.singular

    #Attributes
    attr_accessor "new_related_#{model_string}s"
    attr_accessor "update_related_#{model_string}s"
    attr_accessor "remove_related_#{model_string}s"

    #Callback
    after_save :manage_self_relations

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

  private
    def manage_self_relations
      #Update
      update_related = HashWithIndifferentAccess.new(self.send("update_related_#{self.class.model_name.plural}"))
      unless update_related.blank?
        update_related.each do |k,v|
          record = self.send("related_#{self.class.model_name.param_key}_relations").find_by_id(k)
          if v[:category].starts_with?("-")
            v["#{self.class.model_name.singular}1_id".to_sym] = record.send("#{self.model_name.singular}2_id")
            v["#{self.class.model_name.singular}2_id".to_sym] = record.send("#{self.model_name.singular}1_id")
            v[:category] = v[:category].slice(1..-1)
          end
          record.update_attributes(v) unless record.nil?
        end
      end

      #Destroy
      remove_related = self.send("remove_related_#{self.class.model_name.plural}")
      unless remove_related.blank?
        remove_related.each do |id|
          record = self.send("related_#{self.class.model_name.param_key}_relations").find_by_id(id)
          record.destroy unless record.nil?
        end
      end

      #Create
      create_related = HashWithIndifferentAccess.new(self.send("new_related_#{self.class.model_name.plural}"))
      unless create_related.blank? || create_related[:id].blank? || create_related[:category].blank?
        create_related[:id].zip(create_related[:category]).each do |info|
          record = self.class.find_by_id(info[0])
          unless record.nil?
            if info[1].starts_with?("-")
              self.send("related_#{self.class.model_name.singular}_relations2").create(("#{self.class.model_name.singular}1").to_sym => record, :category => info[1].slice(1..-1))
            else
              self.send("related_#{self.class.model_name.singular}_relations1").create(("#{self.class.model_name.singular}2").to_sym => record, :category => info[1])
            end
          end
        end
      end
    end

end
