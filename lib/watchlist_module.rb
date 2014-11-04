module WatchlistModule
  def watched?(user)
    self.watchlists.where(user_id: user.id).empty? == false    
  end
end
