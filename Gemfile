source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'yaml_db'
gem 'authlogic'
gem 'bcrypt', '~> 3.1.7' #needed for authlogic 3.4.1
gem 'scrypt', '1.2.1' #needed for authlogic 3.4.1
gem 'cancan'
gem 'kaminari' #pagination
gem 'sass-rails',   '>= 3.2'
gem 'bootstrap-sass', '~> 3.2.0.2' #bootstrap
gem 'nokogiri' #Scraping
gem 'mechanize' #Scraping/Posting
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'lazyload-rails'
gem 'mini_magick', '3.5.0' #Image manipulation
gem 'sunspot_rails', github: "betam4x/sunspot" # , '2.1.1'
gem 'sunspot_solr', github: "betam4x/sunspot" # '2.1.1'
gem 'sidekiq', '2.16.1'
gem 'mysql2', '0.3.15'
gem 'whenever', :require => false #Cron job gem
gem 'protected_attributes'
gem 'truncate_html'

group :development, :test do
  gem 'bullet', platforms: [:mingw, :mswin]
  gem 'puma', '2.6.0'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'tzinfo-data', platforms: [:mingw, :mswin]
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'sunspot_test'
end
