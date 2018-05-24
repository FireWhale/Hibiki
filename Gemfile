source 'https://rubygems.org'

gem 'rails', '5.2'
gem 'yaml_db'
gem 'authlogic'
gem 'bcrypt', '~> 3.1.7', platform: 'ruby' #needed for authlogic 3.4.1
gem 'scrypt' #needed for authlogic 3.4.1
gem 'cancancan'
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
gem 'globalize', git: 'https://github.com/globalize/globalize'
gem 'activemodel-serializers-xml' #For globalize
gem 'mojinizer'
gem 'sidekiq'
gem 'mysql2'
gem 'whenever', :require => false #Cron job gem
gem 'truncate_html'
gem 'sunspot_solr' #pre packaged solr distribution (Remove once you install true solr)

group :development, :test do
  gem 'bullet', platforms: [:mingw, :mswin, :x64_mingw] #Raises notices unoptimized queries
  gem 'puma'
  gem 'progress_bar'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw] #timezone data not natively in windows
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
