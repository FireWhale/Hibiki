class RelatedOrganizations < ActiveRecord::Base
  attr_accessible :category, :organization1_id, :organization2_id
  
  belongs_to :organization1, class_name: "Organization", :foreign_key => :organization1_id
  belongs_to :organization2, class_name: "Organization", :foreign_key => :organization2_id
end
