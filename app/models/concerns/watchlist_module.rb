module WatchlistModule
  extend ActiveSupport::Concern
  
  included do
    has_many :watchlists, dependent: :destroy, as: :watched
    has_many :watchers, through: :watchlists, source: :user
    
    scope :watched_by, ->(user_ids) {joins(:watchlists).where('watchlists.user_id IN (?)', user_ids).distinct unless user_ids.nil?}
  end
  
  def watched?(user)
    self.watchlists.select {|a| a.user_id == user.id}.empty? == false
  end        
end
