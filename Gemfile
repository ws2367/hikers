source 'https://rubygems.org'


gem 'sinatra'
gem 'unicorn'
gem 'json'

# for a rake task
gem 'uuidtools'

gem 'rails-api'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# Official API doc: http://api.rubyonrails.org/v3.2.13/
gem 'rails', '3.2.13'

# Annotate models, fixtures and tests
gem 'annotate', ">=2.5.0"

# Because Heroku ask us to do so
ruby '1.9.3'

# Heroku asks us to add this gem to configure my application to be visible
gem 'rails_12factor'

# Use sqlite3 as the database for Active Record in developement 
# and test, pg for production
group :production, :staging do
	gem 'pg'
end
group :development, :test do
	gem 'sqlite3'
end

# Use SCSS for stylesheets
gem 'sass-rails', '3.2.5'
gem 'bootstrap-sass', '~>2.2.2.0' 

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 3.2.2'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'devise', "~> 3.0.0"
gem 'simple_form'
gem 'paperclip', '3.4.2'
gem 'cocaine'
gem 'aws-sdk'

gem 'thin'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem 'faker', '1.1.2'

gem 'will_paginate', '3.0.3'
gem 'bootstrap-will_paginate', '0.0.6'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
