module ImageModule
  extend ActiveSupport::Concern
  
  included do
    has_many :imagelists, dependent: :destroy, as: :model
    has_many :images, through: :imagelists
    has_many :primary_images, -> {where "images.primary_flag <> ''" }, through: :imagelists, source: :image
  end
  
end
