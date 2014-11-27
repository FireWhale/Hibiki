# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #Primary Models - Albums, Artists, Organizations, Sources, Songs
    #factory :album
    #factory :artist 
    #factory :organization 
    #factory :source
    #factory :song
  
  #Secondary Models - Seasons, Events, Tags, Images, Posts, Issues
    #factory :season
    #factory :event 
    #factory :tag
    #factory :image   
    #factory :post 
    #factory :issue 
    
    #Join Tables - Imagelist, Postlist, Taglist, AlbumEvent, SourceSeason
      #factory :imagelist     
      #factory :postlist     
      #factory :taglist 
      #factory :album_event     
      #factory :source_season 
    
  #User Models - User, Collection, IssueUser, Rating, Watchlist
    #factory :user
     
    #factory :collection 
    #factory :issue_user 
    #factory :rating     
    #factory :watchlist 
    
  #Tertiary Models - ability, user_sesion
    #factory :ability
    #factory :user_session
    
  #Primary Join Table Models - A Lot
      
    #factory :album_organization
    #factory :album_source 
    #factory :artist_album 
    #factory :artist_organization
    #factory :artist_song 
    #factory :song_source 
    #factory :source_organization
    
    #factory :related_albums
    #factory :related_artists 
    #factory :related_organizations
    #factory :related_songs     
    #factory :related_sources 
    
  #Secondary Join Table Models
end