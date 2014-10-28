class Collection < ActiveRecord::Base
  attr_accessible :album_id, :rating, :relationship
  
  Relationship = %w[Collected Ignored Watchlist]
  
  validates :album, :presence => true
  validates :user, :presence => true
  validates :user_id, uniqueness: {scope: :album_id}
  validates :relationship, presence: true, inclusion: Collection::Relationship

  belongs_to :album
  belongs_to :user
  
end
