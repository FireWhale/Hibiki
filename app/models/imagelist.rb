class Imagelist < ActiveRecord::Base
   attr_accessible :image_id, :model_id, :model_type
  
  belongs_to :image
  belongs_to :model, polymorphic: :true
end
