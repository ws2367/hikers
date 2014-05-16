require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Moose
  class Application < Rails::Application
    # we let Nginx to do the SSL handling
    # config.force_ssl = true

    # Load bucket_name from the file config/photo_bucket_name
    is_photo_bucket_name_set = false
    if File.exists? 'config/photo_bucket_name'
        File.open('config/photo_bucket_name') {|f| 
            values = f.readline.split('=')
            if values[0].chomp.strip == 'photo_bucket_name'
                PHOTO_BUCKET_NAME = values[1].chomp.strip
                is_photo_bucket_name_set = true
            end
        }
    end
    if is_photo_bucket_name_set
        puts "Set photo bucket name to %s" % PHOTO_BUCKET_NAME
    else
        puts "Failed to set photo bucket name. ***If you are running the server, stop it.***"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    
    # Enable the asset pipeline
    config.assets.enabled = false
    
    # Required for Devise on Heroku
    config.assets.initialize_on_precompile = false

    config.assets.logger = false
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
