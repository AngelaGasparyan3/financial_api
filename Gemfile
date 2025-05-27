# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'active_model_serializers'
gem 'bcrypt', '~> 3.1'
gem 'bootsnap', '~> 1.18.6', require: false
gem 'jbuilder', '~> 2.7'
gem 'jwt', '~> 2.3'
gem 'pg', '~> 1.1'
gem 'pry'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.8.7'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 5.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'delayed_job_active_record'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring', '~> 4.3'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'faker'
  gem 'shoulda-matchers', '~> 5.0'
end

gem 'concurrent-ruby', '< 1.3.4'
gem 'tzinfo-data'
