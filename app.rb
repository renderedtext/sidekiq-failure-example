require "sidekiq"

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379/12' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379/12' }
end

class Worker
  include Sidekiq::Worker

  def perform
    1000.times do |index|
      puts "Working #{index}/10"
      sleep 1
    end
  end
end
