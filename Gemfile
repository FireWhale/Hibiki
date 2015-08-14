source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'yaml_db'
gem 'authlogic'
gem 'bcrypt', '~> 3.1.7' #needed for authlogic 3.4.1
gem 'scrypt', '1.2.1' #needed for authlogic 3.4.1
gem 'cancan'
gem 'kaminari' #pagination
gem 'jbuilder'
gem 'sass-rails',   '>= 3.2'
gem 'bootstrap-sass', '~> 3.2.0.2' #bootstrap
gem 'nokogiri' #Scraping
gem 'mechanize' #Scraping/Posting
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'lazyload-rails'
gem 'mini_magick' #Image manipulation
gem 'sunspot_rails'
gem 'globalize'
gem 'mojinizer'
gem 'sidekiq'
gem 'mysql2'
gem 'whenever', :require => false #Cron job gem
gem 'protected_attributes'
gem 'truncate_html'

group :development, :test do
  gem 'bullet', platforms: [:mingw, :mswin] #Raises notices unoptimized queries
  gem 'puma', '2.6.0'
  gem 'sunspot_solr' #pre packaged solr distribution
  gem 'progress_bar'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'tzinfo-data', platforms: [:mingw, :mswin] #timezone data not natively in windows
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'sunspot_test'
  gem 'json-schema'
end
