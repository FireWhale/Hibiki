Hibiki::Application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'gmail..com',
    user_name:            Rails.application.secrets.mailer_account,
    password:             Rails.application.secrets.mailer_password,
    authentication:       'plain',
    enable_starttls_auto: true  }

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  
  #Disable mailer logging
  config.action_mailer.logger = nil

  #Quiet Assets
  config.assets.quiet = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # Raise error on trying to assign unpermitted parameter (according to strong_params)
  config.action_controller.action_on_unpermitted_parameters = :log
  
  # Do not compress assets
  config.assets.js_compressor = false

  # Expands the lines which load the assets
  config.assets.debug = true
  config.eager_load = false

  #Bullet Monitoring SQL queries
  if RUBY_PLATFORM.downcase == "i386-mingw32"
    config.after_initialize do
      Bullet.enable = false
      Bullet.alert = true
      Bullet.bullet_logger = true
      Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Artist", :association => :watchlists
      Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Source", :association => :watchlists
      Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Organization", :association => :watchlists
      Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Album", :association => :tags
    end
  end

  #Allow Vagrant
  config.web_console.whitelisted_ips = '10.0.2.2'
  
end
