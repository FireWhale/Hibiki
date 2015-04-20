module PostModule
  extend ActiveSupport::Concern
  
  included do
    has_many :postlists, dependent: :destroy, as: :model
    has_many :posts, through: :postlists
  end
  
        
end
