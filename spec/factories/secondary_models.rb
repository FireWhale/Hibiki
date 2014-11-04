# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #Secondary Models - Seasons, Events, Tags, Images, Posts, Issues
    factory :season do
      name {Faker::Lorem.word}
      start_date {Faker::Date.between(2.years.ago, Date.today)}      
      end_date {Faker::Date.between(2.years.ago, Date.today)}    

      trait :with_source_season do
        after(:create) do |season|
          create(:source_season, season: season)
        end
      end 
    end
    
    factory :event do
      name {Faker::Lorem.word}
      shorthand {Faker::Lorem.word}
                  
      trait :with_album_event do
        after(:create) do |event|
          create(:album_event, event: event)
        end
      end 
 
    end
    
    factory :tag do
      name {Faker::Lorem.sentence}
      classification {Faker::Lorem.word}
      model_bitmask 31
      visibility {Faker::Lorem.word}
      
      trait :with_taglist_album do
        after(:create) do |tag|
          create(:taglist, :with_album, tag: tag)
        end        
      end    
      
      trait :with_taglist_artist do
        after(:create) do |tag|
          create(:taglist, :with_artist, tag: tag)
        end        
      end  
      
      trait :with_taglist_organization do
        after(:create) do |tag|
          create(:taglist, :with_organization, tag: tag)
        end        
      end  
      
      trait :with_taglist_song do
        after(:create) do |tag|
          create(:taglist, :with_song, tag: tag)
        end        
      end  
      
      trait :with_taglist_source do
        after(:create) do |tag|
          create(:taglist, :with_source, tag: tag)
        end        
      end  
      
      trait :with_multiple_taglists do
        after(:create) do |tag|
          [:with_album, :with_artist, :with_organization, :with_song, :with_source].each do |model|
            create(:taglist, model, tag: tag)
          end
        end
      end  
    end
    
    factory :image do 
      name {Faker::Lorem.word}
      path {Faker::Lorem.sentence}
      
      trait :with_imagelist_album do
        after(:create) do |image|
          create(:imagelist, :with_album, image: image)
        end        
      end 
      
      trait :with_imagelist_artist do
        after(:create) do |image|
          create(:imagelist, :with_artist, image: image)
        end        
      end 
      
      trait :with_imagelist_organization do
        after(:create) do |image|
          create(:imagelist, :with_organization, image: image)
        end        
      end 
      
      trait :with_imagelist_source do
        after(:create) do |image|
          create(:imagelist, :with_source, image: image)
        end        
      end 

      trait :with_imagelist_song do
        after(:create) do |image|
          create(:imagelist, :with_song, image: image)
        end        
      end 
      
      trait :with_imagelist_user do
        after(:create) do |image|
          create(:imagelist, :with_user, image: image)
        end        
      end 
      
      trait :with_imagelist_post do
        after(:create) do |image|
          create(:imagelist, :with_post, image: image)
        end        
      end 

      trait :with_multiple_imagelists do
        after(:create) do |image|
          [:with_album, :with_artist, :with_organization, :with_user, :with_song, :with_source].each do |model|
            create(:imagelist, model, image: image)
          end
        end
      end           
    end
  
    factory :post do
      category "Rescrape Result"
      visibility {Faker::Lorem.word}
      status {Post::Status.sample}
      
      trait :by_user do
        association :user, factory: :user 
      end
      
      trait :to_recipient do
        association :recipient, factory: :user
      end
      
      trait :with_postlist_album do
        after(:create) do |post|
          create(:postlist, :with_album, post: post)
        end        
      end    
      
      trait :with_postlist_artist do
        after(:create) do |post|
          create(:postlist, :with_artist, post: post)
        end        
      end    
      
      trait :with_postlist_organization do
        after(:create) do |post|
          create(:postlist, :with_organization, post: post)
        end        
      end    
      
      trait :with_postlist_song do
        after(:create) do |post|
          create(:postlist, :with_song, post: post)
        end        
      end    
      
      trait :with_postlist_source do
        after(:create) do |post|
          create(:postlist, :with_source, post: post)
        end        
      end    
      
      trait :with_multiple_postlists do
        after(:create) do |tag|
          [:with_album, :with_artist, :with_organization, 
            :with_song, :with_source, :with_image].each do |model|
            create(:taglist, model, tag:tag)
          end
        end
      end        
    end
  
    factory :issue do
      name {Faker::Lorem.sentence}
      category {Issue::Categories.sample}
      visibility {Faker::Lorem.word}
      status {Issue::Statuses.sample}
      
      trait :with_comments do
        after(:create) do |issue|
          create(:issue_user, issue: issue)
        end
      end
      
      trait :admin_only do
        visibility "Admin"
      end
    end
        
  #Secondary Join Table Models
    factory :imagelist do
      association :image
      association :model, factory: :album
      
      trait :with_album do
        association :model, factory: :album
      end
      
      trait :with_artist do
        association :model, factory: :artist
      end
      
      trait :with_organization do
        association :model, factory: :organization
      end
            
      trait :with_source do
        association :model, factory: :source
      end
      
      trait :with_song do
        association :model, factory: :song
      end
      
      trait :with_user do
        association :model, factory: :user
      end
      
      trait :with_post do
        association :model, factory: :post
      end
            
    end
    
    factory :postlist do 
      association :post
      association :model, factory: :album

      trait :with_album do
        association :model, factory: :album
      end
      
      trait :with_artist do
        association :model, factory: :artist
      end
      
      trait :with_organization do
        association :model, factory: :organization
      end
      
      trait :with_song do
        association :model, factory: :song
      end
      
      trait :with_source do
        association :model, factory: :source
      end
      
    end
    
    factory :taglist do
      association :tag
      association :subject, factory: :album
      
      trait :with_album do
        association :subject, factory: :album
      end
      
      trait :with_artist do
        association :subject, factory: :artist
      end
      
      trait :with_organization do
        association :subject, factory: :organization
      end
      
      trait :with_song do
        association :subject, factory: :song
      end
      
      trait :with_source do
        association :subject, factory: :source
      end
    end
    
    factory :album_event do
      association :album
      association :event
    end
    
    factory :source_season do
      category {SourceSeason::Categories.sample}
      association :source
      association :season
    end
end