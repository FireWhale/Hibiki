class Postlist < ActiveRecord::Base
   attr_accessible :post_id, :model_id, :model_type
  
  belongs_to :post
  belongs_to :model, polymorphic: :true
end
