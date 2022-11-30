require_relative "boot"

require "rails/all"
require "net/http" # workaround for AzureActiveDirectory error

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Azure1
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # config.middleware.use Rack::Session::Cookie, key: 'rack.session', path: '/', expire_after: 14400, secret: "87b781359a8a898bce0d1cda7ac66ca5fcd9d9dfca00433c0cebaa1908fef257efb6a3748aae7c972f6b23ac5ce8eb6e5d656c97020f81612b9c432b9ec6400d"

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
