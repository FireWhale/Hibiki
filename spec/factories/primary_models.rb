# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #Primary Models - Albums, Artists, Organizations, Sources, Songs
    factory :album do    
      internal_name {Faker::Lorem.sentence}
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
      
      trait :full_attributes do
        synonyms {Faker::Lorem.sentence}
        info {Faker::Lorem.sentence}
        release_date {Faker::Date.between(2.years.ago, Date.today)}
        release_date_bitmask { 6 }
        
        after(:create) do |record|
          record.write_attribute(:name, "hi", locale: :hibiki_en)
          record.write_attribute(:info, "ho", locale: :hibiki_en)
          record.save
        end
      end
      
      trait :invalid do
        internal_name ""
      end
    end
    
    factory :artist do 
      internal_name {Faker::Name.name}
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
      
      trait :full_attributes do
        synonyms {Faker::Lorem.sentence}
        info {Faker::Lorem.sentence}
        with_albums
        gender {Faker::Lorem.sentence}
        birth_place {Faker::Lorem.sentence}
        blood_type {Faker::Lorem.word}
        birth_date {Faker::Date.between(2.years.ago, Date.today)}
        birth_date_bitmask { 6 }
        debut_date {Faker::Date.between(2.years.ago, Date.today)}
        debut_date_bitmask { 6 }
        
        after(:create) do |record|
          record.write_attribute(:name, "hi", locale: :hibiki_en)
          record.write_attribute(:info, "ho", locale: :hibiki_en)
          record.save
        end
      end
      
      trait :invalid do
        internal_name ""
      end
    end
    
    factory :organization do 
      internal_name {Faker::Lorem.sentence}
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
      
      trait :full_attributes do
        synonyms {Faker::Lorem.sentence}
        with_albums
        info {Faker::Lorem.sentence}
        established {Faker::Date.between(2.years.ago, Date.today)}
        established_bitmask { 6 }
        
        after(:create) do |record|
          record.write_attribute(:name, "hi", locale: :hibiki_en)
          record.write_attribute(:info, "ho", locale: :hibiki_en)
          record.save
        end
      end
            
      trait :invalid do
        internal_name ""
      end
    end
    
    factory :source do 
      internal_name {Faker::Lorem.sentence}
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
      
      trait :full_attributes do
        synonyms {Faker::Lorem.sentence}
        info {Faker::Lorem.sentence}
        with_albums
        plot_summary {Faker::Lorem.sentence}
        release_date {Faker::Date.between(2.years.ago, Date.today)}
        release_date_bitmask { 6 }
        end_date {Faker::Date.between(2.years.ago, Date.today)}
        end_date_bitmask { 6 }

        after(:create) do |record|
          record.write_attribute(:name, "hi", locale: :hibiki_en)
          record.write_attribute(:info, "ho", locale: :hibiki_en)
          record.save
        end
      end
      
      trait :invalid do
        internal_name ""
      end
    end
    
    factory :song do 
      internal_name {Faker::Lorem.sentence}
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
      
      trait :full_attributes do
        synonyms {Faker::Lorem.sentence}
        with_album
        track_number { "15"}
        disc_number { "5" }
        length {Faker::Number.number(3)}
        info {Faker::Lorem.sentence}
        lyrics {Faker::Lorem.sentence}
        release_date {Faker::Date.between(2.years.ago, Date.today)}
        release_date_bitmask { 6 }

        after(:create) do |record|
          record.write_attribute(:name, "hi", locale: :hibiki_en)
          record.write_attribute(:info, "ho", locale: :hibiki_en)
          record.save
        end
      end
      
      trait :invalid do
        internal_name ""
      end
    end
end