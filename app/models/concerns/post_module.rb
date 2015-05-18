module PostModule
  extend ActiveSupport::Concern
  
  included do
    has_many :postlists, dependent: :destroy, as: :model
    has_many :posts, through: :postlists
    
    before_destroy :modify_post_status
  end
  
  private
  
  def modify_post_status
    posts.each do |post|
      post.update(:status => "Deleted Records")
    end
  end
  
        
end
