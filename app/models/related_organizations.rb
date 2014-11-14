class RelatedOrganizations < ActiveRecord::Base
  attr_accessible :category, :organization1_id, :organization2_id
  
  validates :organization1_id, :presence => true, uniqueness: {scope: :organization2_id}
  validates :organization2_id, :presence => true
  validates :category, inclusion: Organization::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?)
  validates :organization1, :presence => true
  validates :organization2, :presence => true
  validates_different_models :organization1, model: "organization"
  validates_unique_combination :organization1, model: "organization" 
  
  belongs_to :organization1, class_name: "Organization", :foreign_key => :organization1_id
  belongs_to :organization2, class_name: "Organization", :foreign_key => :organization2_id
end