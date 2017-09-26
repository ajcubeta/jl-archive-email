source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
gem 'puma', '~> 3.7'
gem 'pg', '~> 0.18'
gem 'devise'
gem 'sass-rails', '~> 5.0'
gem 'uglifier'
gem 'turbolinks', '~> 5.0.0'
gem 'bcrypt', '~> 3.1.7'
gem 'active_model_serializers', '~> 0.10.0'
gem 'kaminari'
gem 'whenever'
gem 'oink'
gem 'bson_ext'
gem 'postmark-rails'
gem 'rest-client'
gem 'jbuilder'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'awesome_print'
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry-rails'
  gem 'rails_best_practices'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'byebug'
end

# For Heroku required for twelve-factor platforms apps
gem 'rails_12factor', group: :production
# Declared ruby version explicitly
ruby "2.4.1"
