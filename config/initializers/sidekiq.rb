Sidekiq.configure_server do |config|
  #config.redis = { :url => 'redis://localhost:6379/12' }
  config.redis = { :size => 25 }
end

Sidekiq.configure_client do |config|
  config.redis = { :size => 5 }
end
