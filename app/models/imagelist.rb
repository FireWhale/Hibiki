class Imagelist < ActiveRecord::Base
   attr_accessible :image_id, :model_id, :model_type
  
  #Associations
    belongs_to :image
    belongs_to :model, polymorphic: :true
    
  #Validations
    validates :image, presence: true
    validates :model, presence: true
    validates :image_id, uniqueness: {scope: [:model_id, :model_type]}
end
