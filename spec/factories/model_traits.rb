require 'faker'

FactoryBot.define do
  #Polymorphics!
  trait(:with_image) {after(:create) {|record| create(:imagelist, model: record)}}
  trait(:with_post) {after(:create) { |record| create(:postlist, model: record)}}
  trait(:with_log) {after(:create) { |record| create(:loglist, model: record)}}
  trait(:with_tag) {after(:create) {|record| create(:taglist, subject: record)}}
  trait(:with_watcher) {after(:create) { |record| create(:watchlist, watched: record)}}
  trait(:with_collector) {after(:create) {|record| create(:collection, collected: record)}}
  trait(:with_reference) {after(:create) { |record| create(:reference, model: record)}}

  #Commonly used traits among multiple factories
  # with_info is no longer used since all the info fields are translated
  # trait(:with_info) {info {Faker::Lorem.paragraphs(2)}}
  trait(:with_private_info) {private_info {Faker::Lorem.paragraphs(2)}}

  #Translated field traits
  [:name, :info, :lyrics, :abbreviation].each do |field|
    trait "with_#{field}_translations".to_sym do
      after :build do |record|
        record.write_attribute(field, "English!", locale: :hibiki_en)
        record.write_attribute(field, "this be ro", locale: :hibiki_ro)
      end
    end
  end

  trait :name_form_attributes do
    name_langs {{hibiki_en: "OLD ENG", hibiki_jp: "JP!"}}
    new_name_langs ["This be romaji!"]
    new_name_lang_categories ["hibiki_ro"]
  end

  trait :info_form_attributes do
    info_langs {{hibiki_en: "OLD ENG", hibiki_jp: "JP!"}}
    new_info_langs ["This be romaji!"]
    new_info_lang_categories ["hibiki_ro"]
  end

  trait :lyrics_form_attributes do
    lyrics_langs {{hibiki_en: "OLD ENG", hibiki_jp: "JP!"}}
    new_lyrics_langs ["This be romaji!"]
    new_lyrics_lang_categories ["hibiki_ro"]
  end

  trait :abbreviation_form_attributes do
    abbreviation_langs {{hibiki_en: "OLD ENG", hibiki_jp: "JP!"}}
    new_abbreviation_langs ["This be romaji!"]
    new_abbreviation_lang_categories ["hibiki_ro"]
  end

  trait :image_form_attributes do
    new_images {Rack::Test::UploadedFile.new(File.new(Rails.root.join("spec/support/data/test_image.png"), 'rb'), nil, true)}
  end

  trait :reference_form_attributes do
    update_references {{"5" => {url: "haha!", site_name: Reference::SiteNames.sample}}}
    new_references {{"site_name" => Reference::SiteNames.sample(2), "url" => ["A URL", "two urls"]}}
  end

end