# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Factory Girl Syntax
  config.include FactoryGirl::Syntax::Methods
  #Controller
  config.include CrudTests, type: :controller
  config.include ImageRouteTests, type: :controller

  #Model
  config.include AssociationTests, type: :model
  config.include AttributeTests, type: :model
  config.include GlobalModelTests, type: :model
  config.include ImageTests, type: :model
  config.include LanguageTests, type: :model
  config.include PaginationTests, type: :model
  config.include PostTests, type: :model
  config.include ScopingTests, type: :model
  config.include SearchTests, type: :model
  config.include TagTests, type: :model
  config.include WatchlistTests, type: :model

  #database cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  #Using expect and/or should
  config.expect_with :rspec do |c|
    # Just use expect
    c.syntax = :expect
  end

  #Capybara wait time
  Capybara.default_max_wait_time = 5

  #automatically tags controllers as controllers and so forth
  config.infer_spec_type_from_file_location!
end
