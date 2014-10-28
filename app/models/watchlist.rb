class Watchlist < ActiveRecord::Base
  attr_accessible :user_id, :watched_id, :watched_type
  
  validates :watched_type, inclusion: %w[Artist Organization Source]
  validates :user, presence: true
  validates :watched, presence: true
  validates_uniqueness_of :user_id, :scope => [:watched_id, :watched_type]
  
  belongs_to :user
  belongs_to :watched, polymorphic: true
  
end
