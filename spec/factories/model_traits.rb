FactoryGirl.define do
  #Polymorphics!
    trait :with_image do
      after(:create) do |record|
        create(:imagelist, model: record)
      end
    end
    
    trait :with_post do
      after(:create) do |record|
        create(:postlist, model: record)
      end
    end
    
    trait :with_tag do
      after(:create) do |record|
        create(:taglist, subject: record)
      end
    end
    
    trait :with_watchlist do
      after(:create) do |record|
        create(:watchlist, watched: record)
      end    
    end
end