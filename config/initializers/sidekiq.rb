require 'sidekiq'
require 'sidekiq-status'

Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
    config.server_middleware do |chain|
        chain.add Sidekiq::Status::ServerMiddleware, expiration: 24.hours # default
    end
    config.client_middleware do |chain|
        chain.add Sidekiq::Status::ClientMiddleware, expiration: 24.hours # default
    end
end

Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
    config.client_middleware do |chain|
        chain.add Sidekiq::Status::ClientMiddleware, expiration: 24.hours # default
    end
end