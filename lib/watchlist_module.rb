module WatchlistModule
  def watched?(user)
    self.watchlists.select {|a| a.user_id == user.id}.empty? == false    
  end
end
