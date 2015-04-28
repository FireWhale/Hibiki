# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #Primary Models - Albums, Artists, Organizations, Sources, Songs
    factory :album do    
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}
      catalog_number {Faker::Lorem.word}
      
      trait :with_release_date do
        release_date {Faker::Date.backward(1000)}
        release_date_bitmask {0}
      end

      trait :with_self_relation do
        after(:create) do |record|
          create(:related_albums, album1: record)
          create(:related_albums, album2: record)
        end            
      end
      
      trait :with_primary_relations do
        after(:create) do |record|
          create(:album_source, album: record)
          create(:artist_album, album: record)
          create(:album_organization, album: record)
        end            
      end

      trait :with_collection do
        after(:create) do |record|
          create(:collection, album: record)
        end
      end

      trait :with_album_event do
        after(:create) do |record|
          create(:album_event, album: record)
        end
      end
      
      trait :with_song do
        after(:create) do |record|
          create(:song, album: record)
        end
      end
      
      trait :with_songs do
        after(:create) do |record|
          create_list(:song, 6, album: record)
        end
      end
      
      trait :invalid do
        name ""
      end
    end
    
    factory :artist do 
      name {Faker::Name.name}
      status {Album::Status.sample}

      trait :with_self_relation do
        after(:create) do |record|
          create(:related_artists, artist1: record)
          create(:related_artists, artist2: record)
        end            
      end
      
      trait :with_primary_relations do
        after(:create) do |record|
          create(:artist_album, artist: record)
          create(:artist_organization, artist: record)
          create(:artist_song, artist: record)
        end            
      end
      
      trait :with_albums do
        after(:create) do |record|
          5.times do
            album = create(:album, :with_release_date)
            create(:artist_album, artist: record, album: album)
          end
        end
      end
      
      trait :invalid do
        name ""
      end
    end
    
    factory :organization do 
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}

      trait :with_self_relation do
        after(:create) do |record|
          create(:related_organizations, organization1: record)
          create(:related_organizations, organization2: record)
        end            
      end
      
      trait :with_primary_relations do
        after(:create) do |record|
          create(:album_organization, organization: record)
          create(:artist_organization, organization: record)
          create(:source_organization, organization: record)
        end            
      end
      
      trait :with_albums do
        after(:create) do |record|
          5.times do
            album = create(:album, :with_release_date)
            create(:album_organization, organization: record, album: album)
          end
        end
      end
            
      trait :invalid do
        name ""
      end
    end
    
    factory :source do 
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}
  
      trait :with_self_relation do
        after(:create) do |record|
          create(:related_sources, source1: record)
          create(:related_sources, source2: record)
        end            
      end
      
      trait :with_primary_relations do
        after(:create) do |record|
          create(:album_source, source: record)
          create(:source_organization, source: record)
          create(:song_source, source: record)
        end            
      end
      
      trait :with_source_season do
        after(:create) do |record|
          create(:source_season, source: record)
        end
      end
            
      trait :with_albums do
        after(:create) do |record|
          5.times do
            album = create(:album, :with_release_date)
            create(:album_source, source: record, album: album)
          end
        end
      end
      
      trait :invalid do
        name ""
      end
    end
    
    factory :song do 
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}
      
      trait :with_album do
        association :album
      end
      
      trait :with_self_relation do
        after(:create) do |record|
          create(:related_songs, song1: record)
          create(:related_songs, song2: record)
        end            
      end
      
      trait :with_primary_relations do
        after(:create) do |record|
          create(:artist_song, song: record)
          create(:song_source, song: record)
        end            
      end
      
      trait :with_lyric do
        after(:create) do |record|
          create(:lyric, song: record)
        end
      end
      
      trait :invalid do
        name ""
      end
    end
end