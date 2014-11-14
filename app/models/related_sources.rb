class RelatedSources < ActiveRecord::Base
  attr_accessible :category, :source1_id, :source2_id

  validates :source1_id, :presence => true, uniqueness: {scope: :source2_id}
  validates :source2_id, :presence => true
  validates :category, inclusion: Source::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?)
  validates :source1, :presence => true
  validates :source2, :presence => true
  validates_different_models :source1, model: "source"
  validates_unique_combination :source1, model: "source"
  
  belongs_to :source1, class_name: "Source", :foreign_key => :source1_id
  belongs_to :source2, class_name: "Source", :foreign_key => :source2_id
  
end