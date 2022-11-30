Devise.setup do |config|

  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  # AzureAD App Credentials
  config.omniauth(
    :azure_activedirectory_v2,
    { client_id:     ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      tenant_id:     ENV['TENANT_ID']
    }
  )

end
