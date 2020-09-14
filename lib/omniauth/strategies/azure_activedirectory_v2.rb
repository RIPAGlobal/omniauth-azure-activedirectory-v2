require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class AzureActivedirectoryV2 < OmniAuth::Strategies::OAuth2
      BASE_AZURE_URL = 'https://login.microsoftonline.com'

      option :name, 'azure_activedirectory_v2'
      option :tenant_provider, nil

      DEFAULT_SCOPE = 'openid profile email'
      USER_INFO_URL = 'https://graph.microsoft.com/v1.0/me'

      # tenant_provider must return client_id, client_secret and optionally tenant_id and base_azure_url
      args [:tenant_provider]

      def client
        if options.tenant_provider
          provider = options.tenant_provider.new(self)
        else
          provider = options  # if pass has to config, get mapped right on to options
        end

        options.client_id = provider.client_id
        options.client_secret = provider.client_secret
        options.tenant_id =
            provider.respond_to?(:tenant_id) ? provider.tenant_id : 'common'
        options.base_azure_url =
            provider.respond_to?(:base_azure_url) ? provider.base_azure_url : BASE_AZURE_URL

        options.authorize_params = provider.authorize_params if provider.respond_to?(:authorize_params)
        options.authorize_params.domain_hint = provider.domain_hint if provider.respond_to?(:domain_hint) && provider.domain_hint
        options.authorize_params.prompt = request.params['prompt'] if defined? request && request.params['prompt']
        options.authorize_params.scope = (provider.scope if provider.respond_to?(:scope) && provider.scope) || DEFAULT_SCOPE

        options.client_options.authorize_url = "#{options.base_azure_url}/#{options.tenant_id}/oauth2/v2.0/authorize"
        options.client_options.token_url = "#{options.base_azure_url}/#{options.tenant_id}/oauth2/v2.0/token"

        super
      end

      uid {
        raw_info['id']
      }

      info do
        {
            name: raw_info['displayName'],
            first_name: raw_info['givenName'],
            last_name: raw_info['surname'],
            email: raw_info['userPrincipalName'],
            id: raw_info['id'],
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_URL).parsed
      end

    end
  end
end