source 'https://rubygems.org'

gem 'foreman'

# Use for GTFS-R fetching/parsing
gem 'ruby-protocol-buffers'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil # sidekiq web UI
gem 'slim', :require => nil #sidekiq web UI
gem 'whenever'

# Use for GTFS-R viz
gem 'rabl'
gem 'mapbox-rails'

# Use for GTFS-R loading
gem 'foreigner', '1.2.1'
gem 'activerecord-import'
gem 'rubyzip'
gem 'time_zone_ext'

gem 'haml'

group :development do
  gem 'puppet'
  gem 'debugger'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'

  gem 'guard-rspec'
  gem 'rb-fsevent', '~> 0.9.1' # for OSX

  # gem 'fakeredis', :require => 'fakeredis/rspec' # pubsub not supported
end

gem 'rails', '4.0.0'
gem 'sqlite3'

gem 'handlebars_assets'

# Use Bootstrap with Less support
gem 'therubyracer', :platforms => :ruby
gem 'less-rails'
gem 'twitter-bootstrap-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

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

