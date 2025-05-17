source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.0.8.7' # Use the latest Rails 7.0.x that is more compatible
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'jwt', '~> 2.3'
gem 'bcrypt', '~> 3.1'
gem 'pry'
gem 'rspec-rails'

# Use Bootsnap for faster app startup
gem 'bootsnap', '~> 1.18.6', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring', '~> 4.3' # Compatible with Rails 7.0.x
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
  gem 'faker'
end

# Fix tzinfo-data for non-Windows platforms
gem 'tzinfo-data'
gem 'concurrent-ruby', '< 1.3.4'
