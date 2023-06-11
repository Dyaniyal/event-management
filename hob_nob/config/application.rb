require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Shobiz
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.exceptions_app = self.routes
    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.observers = :logging_observer
   
    # config.assets.version = '1.0'
    config.action_mailer.default_url_options = { host: 'hobnobspace.com'}
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
                                            :user_name => "apikey",
                                            :password => "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",
                                            :domain => "support@hobnobspace.com",
                                            :address => "smtp.sendgrid.net",
                                            :port => 587,
                                            :authentication => :plain,
                                            :enable_starttls_auto => true
                                          }
    # config.action_mailer.smtp_settings = {
    #                                         :user_name => "AKIAJIMELKZO4DNFQHUQ",
    #                                         :password => "AhBEaoHJLWfTJqz0Yw1XQIWZ4N+8vT9spPPBV+dWJia3",
    #                                         :domain => "hobnobspace.com",
    #                                         :address => "email-smtp.us-east-1.amazonaws.com",
    #                                         :port => 587,
    #                                         :authentication => :plain,
    #                                         :enable_starttls_auto => true
    #                                       }
  end
end
CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key        = "l36MiSnVI2UqgAYxOsYFLbm7S"
  config.consumer_secret     = "wHIrVfUgydhS5P42HAY75GrgNsCuZw9EvtOTX4oMUbyHw0Lk02"
  config.access_token        = "2933082606-OhYQcv8uwHkOnBKGSiTbTN9fWCJ4JCYe7jB8K8Q"
  config.access_token_secret = "rXNHhQVO5lxwJCWe3DFbI4U6A9cpPWX0VoE2JsWaNdPpt"
end