class Imagelist < ActiveRecord::Base
  attr_accessible :image_id, :model_id, :model_type
  after_destroy :destroy_image_on_condition
  
  #Associations
    belongs_to :image
    belongs_to :model, polymorphic: :true
    
  #Validations
    validates :image, presence: true
    validates :model, presence: true
    validates :image_id, uniqueness: {scope: [:model_id, :model_type]}
    
  private
    def destroy_image_on_condition
      #If there are no other imagelists attached to the image, destroy the image as well
      unless self.image.imagelists.count >= 1
        self.image.destroy
      end
    end
end
