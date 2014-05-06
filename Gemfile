source 'https://rubygems.org'


gem 'unicorn'
gem 'json'

# Rendering json
gem 'rabl'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj'

# for push notification
gem 'houston'

# bulk insert! import in batch
gem "activerecord-import", ">= 0.2.0"

# for a rake task
gem 'uuidtools'

# reduce the redundancy and make the action controller faster 
gem 'rails-api'

# Facebook SDK
gem "koala", "~> 1.8.0rc1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# Official API doc: http://api.rubyonrails.org/v3.2.13/
gem 'rails', '3.2.13'

# Annotate models, fixtures and tests
gem 'annotate', ">=2.5.0"

# Because Heroku ask us to do so
# ruby '1.9.3'

# Use sqlite3 as the database for Active Record in developement 
# and test, pg for production
group :production, :staging do
	gem 'pg'
end
group :development, :test do
	gem 'sqlite3'
end

gem 'devise', "~> 3.0.0"

gem 'aws-sdk'

gem 'thin'

gem 'faker', '1.1.2'



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
