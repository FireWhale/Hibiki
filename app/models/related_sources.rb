class RelatedSources < ActiveRecord::Base
  attr_accessible :category, :source1_id, :source2_id
  
  belongs_to :source1, class_name: "Source", :foreign_key => :source1_id
  belongs_to :source2, class_name: "Source", :foreign_key => :source2_id
end
