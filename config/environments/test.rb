Hibiki::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
  
  config.eager_load = false

  #Testing
    #In Rails 5.0, tests will be executed randomly. to opt in (yes we are opting in),
    config.active_support.test_order = :random

    #Rspec and Testing Code
    config.generators do |g|
      g.test_framework :rspec,
                       :fixtures => true,
                       :view_specs => true,
                       :helper_specs => false,
                       :routing_specs => false,
                       :controller_specs => true,
                       :request_specs => true
      g.fixture_replacement :factory_bot, :dir => "spec/factories"
    end



  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = true
  end
end
