Sidekiq.configure_server do |config|
  config.options[:concurrency] = Integer(ENV["SIDEKIQ_THREADS"] || 5)
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } }
  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger
end

Sidekiq.configure_client do |config|
  config.redis = {
    size: Integer(ENV["RAILS_MAX_THREADS"] || 5),
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
  }
end

ActiveSupport.on_load(:active_job) do
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file("config/schedule.yml") if Sidekiq.server?
end

unless Sidekiq.server?
  require "sidekiq/web"
  require "sidekiq/cron/web"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:username])
    ) & ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:password])
    )
  end
end
