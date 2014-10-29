# encoding: utf-8
require 'faker' 

FactoryGirl.define do    
  #Primary Join Table Models - A Lot
    factory :album_organization do
      category {AlbumOrganization::Categories.sample}
      association :album
      association :organization
    end
    
    factory :album_source do
      association :album
      association :source
    end
    
    factory :artist_album do
      category {Array(1..(2**Artist::Credits.count - 1)).sample}
      association :artist
      association :album
    end
    
    factory :artist_organization do
      category {ArtistOrganization::Categories.sample}
      association :artist
      association :organization
    end
    
    factory :artist_song do 
      category {Array(1..(2**Artist::Credits.count - 1)).sample}
      association :artist
      association :song    
    end
    
    factory :song_source do 
      classification {SongSource::Relationship.sample}
      association :song
      association :source
    end
    
    factory :source_organization do
      category {SourceOrganization::Categories.sample}
      association :source
      association :organization
    end
    
    factory :related_albums do 
      association :album1, :factory => :album
      association :album2, :factory => :album
      category Album::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?).sample
    end
    
    factory :related_artists do 
      association :artist1, :factory => :artist
      association :artist2, :factory => :artist
      category Artist::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?).sample
    end
    
    factory :related_organizations do
      association :organization1, :factory => :organization
      association :organization2, :factory => :organization
      category Organization::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?).sample
    end
    
    factory :related_songs do
      association :song1, :factory => :song
      association :song2, :factory => :song
      category Song::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?).sample
    end
    
    factory :related_sources do 
      association :source1, :factory => :source
      association :source2, :factory => :source
      category Source::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?).sample
    end
end