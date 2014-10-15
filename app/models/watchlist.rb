class Watchlist < ActiveRecord::Base
  attr_accessible :user_id, :watched_id, :watched_type
  
  belongs_to :user
  belongs_to :watched, polymorphic: true
  
  validates_uniqueness_of :user_id, :scope => [:watched_id, :watched_type]
end
