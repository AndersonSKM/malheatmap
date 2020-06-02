source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.6"

gem "bootsnap", require: false
gem "chronic"
gem "mechanize"
gem "pg"
gem "puma"
gem "rails"
gem "rollbar"
gem "sass-rails"
gem "sidekiq"
gem "sidekiq-limit_fetch"
gem "turbolinks"
gem "webpacker"

group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"
end

group :development do
  gem "brakeman"
  gem "listen"
  gem "reek"
  gem "rubocop"
  gem "rubocop-rails", require: false
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
end
