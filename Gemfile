source 'https://rubygems.org'

ruby '2.3.3' #current ruby version!

gem 'rails', '>= 5.2.0'
gem 'yaml_db'
gem 'authlogic'
gem 'bcrypt', '~> 3.1.7', platform: 'ruby' #needed for authlogic 3.4.1
gem 'scrypt' #needed for authlogic 3.4.1
gem 'cancancan' #Authorization
gem 'kaminari' #pagination
gem 'jbuilder' #JSON api builder
gem 'sass-rails', '>= 3.2'
gem 'bootstrap-sass', '~> 3.2.0.2' #bootstrap
gem 'nokogiri' #Scraping
gem 'mechanize' #Scraping/Posting
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'lazyload-rails'
gem 'turbolinks'
gem 'mini_magick' #Image manipulation
gem 'sunspot_rails'
gem 'globalize', git: 'https://github.com/globalize/globalize'
gem 'activemodel-serializers-xml' #For globalize
gem 'mojinizer'
gem 'sidekiq'
gem 'mysql2'
gem 'whenever', :require => false #Cron job gem
gem 'truncate_html'
gem 'neo4j' #Neo4J graph database
gem 'neo4j-rake_tasks' #rake tasts for neo4j
gem 'd3-rails' #graphing library
gem 'puma' #Server
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem 'sunspot_solr' #pre packaged solr distribution (Remove once you install true solr)
  gem 'progress_bar'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'uglifier', '>= 1.0.3' #timezone data not natively in windows
end

group :development do
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'bullet'
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'sunspot_test'
  gem 'json-schema'
  gem 'coveralls', require: false
  gem 'simplecov', require: false
end
