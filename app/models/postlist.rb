class Postlist < ApplicationRecord
  belongs_to :post
  belongs_to :model, polymorphic: :true
  
  #Validations
    validates :post_id, uniqueness: {scope: [:model_id, :model_type]}
    validates :post, presence: true
    validates :model, presence: true
end
