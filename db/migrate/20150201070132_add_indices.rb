class AddIndices < ActiveRecord::Migration
  def change
    add_index :album_events, :album_id
    add_index :album_events, :event_id
    add_index :album_sources, :album_id
    add_index :album_sources, :source_id
    add_index :collections, :relationship
    add_index :events, :start_date
    add_index :events, :end_date
    add_index :events, :abbreviation
    add_index :events, :altname
    add_index :events, :db_status
    add_index :events, :shorthand
    add_index :images, :rating
    add_index :issue_users, :issue_id
    add_index :issue_users, :user_id
    add_index :issues, :category
    add_index :issues, :status
    add_index :issues, :priority
    add_index :issues, :visibility
    add_index :issues, :resolution
    add_index :issues, :difficulty
    add_index :issues, :created_at
    add_index :issues, :updated_at
    add_index :lyrics, :song_id
    add_index :lyrics, :language
    add_index :organizations, :popularity
    add_index :postlists, :post_id
    add_index :postlists, :model_id
    add_index :postlists, :model_type
    add_index :posts, :user_id
    add_index :posts, :category
    add_index :posts, :visibility
    add_index :posts, :status
    add_index :posts, :recipient_id
    add_index :ratings, :favorite
    add_index :related_albums, :album1_id 
    add_index :related_albums, :album2_id 
    add_index :related_albums, :category
    add_index :related_artists, :artist1_id 
    add_index :related_artists, :artist2_id 
    add_index :related_artists, :category
    add_index :related_organizations, :organization1_id 
    add_index :related_organizations, :organization2_id 
    add_index :related_organizations, :category
    add_index :related_songs, :song1_id 
    add_index :related_songs, :song2_id 
    add_index :related_songs, :category
    add_index :related_sources, :source1_id 
    add_index :related_sources, :source2_id 
    add_index :related_sources, :category
    add_index :seasons, :start_date
    add_index :seasons, :end_date
    add_index :song_sources, :song_id
    add_index :song_sources, :source_id
    add_index :song_sources, :classification
    add_index :songs, :altname
    add_index :songs, :status
    add_index :songs, :track_number
    add_index :songs, :disc_number
    add_index :songs, :release_date
    add_index :source_organizations, :source_id
    add_index :source_organizations, :organization_id
    add_index :source_organizations, :category
    add_index :source_seasons, :source_id
    add_index :source_seasons, :season_id
    add_index :source_seasons, :category
    add_index :sources, :end_date
    add_index :tags, :visibility
    
    
  end
end
