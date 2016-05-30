class Imagelist < ActiveRecord::Base

  #Callbacks/Hooks
    after_destroy :destroy_images

  #Validations
    validates :image, presence: true
    validates :model, presence: true
    validates :image_id, uniqueness: {scope: [:model_id, :model_type]}

  #Associations
    belongs_to :image
    belongs_to :model, polymorphic: :true

  private
    def destroy_images
      self.image.destroy if self.image.imagelists.empty?
    end
end
