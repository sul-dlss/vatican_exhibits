source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.13'
gem 'mysql2', group: :production
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'blacklight', ' ~> 6.0'
gem 'blacklight-spotlight', '~> 2.0'
group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
end

group :test do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'webdrivers'
  gem 'selenium-webdriver', '>= 3.13.1'
  gem 'simplecov'
  gem 'webmock'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq'
end

gem 'rsolr', '>= 1.0', '< 3'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'friendly_id'
gem 'riiif', '~> 2.0'
gem 'sitemap_generator'
gem 'blacklight-gallery', '>= 0.3.0'
gem 'blacklight-hierarchy'
gem 'blacklight-oembed', '>= 0.1.0'
gem 'devise_invitable'
gem 'config'
gem 'sidekiq'
gem 'traject'
gem 'traject_plus'
gem 'rack-cors', require: 'rack/cors'
gem 'mirador_rails'
gem 'annotot'

gem 'okcomputer'
gem 'honeybadger'
gem 'oauth2', '~> 1.4' # prevent oauth2 (dependency of blacklight-spotlight) from being downgraded
gem 'faraday'
