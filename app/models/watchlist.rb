class Watchlist < ActiveRecord::Base
  attr_accessible :user_id, :watched_id, :watched_type,
                  :position, :grouping_category
    
  validates :watched_type, inclusion: %w[Artist Organization Source]
  validates :user, presence: true
  validates :watched, presence: true
  validates_uniqueness_of :user_id, :scope => [:watched_id, :watched_type]

  validates :grouping_category, length: {maximum: 40}, allow_nil: true, allow_blank: true
  
  belongs_to :user
  belongs_to :watched, polymorphic: true
  
  
  
end
