class Collection < ActiveRecord::Base
  attr_accessible :album_id, :rating, :user_id, :relationship
  
  belongs_to :album
  belongs_to :user
  
  validates_uniqueness_of :user_id, :scope => [:album_id]
end
