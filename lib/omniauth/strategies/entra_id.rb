# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class EntraId < OmniAuth::Strategies::OAuth2
      BASE_URL = 'https://login.microsoftonline.com'

      option :name,            'entra_id'
      option :tenant_provider, nil
      option :jwt_leeway,      60

      DEFAULT_SCOPE = 'openid profile email'

      # The tenant_provider must return client_id, client_secret and,
      # optionally, tenant_id and base_url.
      #
      args [:tenant_provider]

      def client
        provider = if options.tenant_provider
          options.tenant_provider.new(self)
        else
          options
        end

        options.client_id = provider.client_id

        if provider.respond_to?(:client_secret) && provider.client_secret
          options.client_secret = provider.client_secret
        elsif provider.respond_to?(:certificate_path) && provider.respond_to?(:tenant_id) && provider.certificate_path && provider.tenant_id
          options.token_params = {
            tenant:                provider.tenant_id,
            client_id:             provider.client_id,
            client_assertion:      client_assertion(provider.tenant_id, provider.client_id, provider.certificate_path),
            client_assertion_type: client_assertion_type
          }
        else
          raise ArgumentError, "You must provide either client_secret or certificate_path and tenant_id"
        end

        options.tenant_id = if provider.respond_to?(:tenant_id)
          provider.tenant_id
        else
          'common'
        end

        options.base_url = if provider.respond_to?(:base_url )
          provider.base_url
        else
          BASE_URL
        end

        options.tenant_name                  = provider.tenant_name      if provider.respond_to?(:tenant_name)
        options.custom_policy                = provider.custom_policy    if provider.respond_to?(:custom_policy)
        options.authorize_params             = provider.authorize_params if provider.respond_to?(:authorize_params)
        options.authorize_params.domain_hint = provider.domain_hint      if provider.respond_to?(:domain_hint) && provider.domain_hint
        options.authorize_params.prompt      = request.params['prompt']  if defined?(request) && request.params['prompt']

        options.authorize_params.scope = if defined?(request) && request.params['scope']
          request.params['scope']
        elsif provider.respond_to?(:scope) && provider.scope
          provider.scope
        else
          DEFAULT_SCOPE
        end

        oauth2 = if provider.respond_to?(:adfs?) && provider.adfs?
          'oauth2'
        else
          'oauth2/v2.0'
        end

        base_url = if options.custom_policy && options.tenant_name
          "https://#{options.tenant_name}.b2clogin.com/#{options.tenant_name}.onmicrosoft.com/#{options.custom_policy}"
        else
          "#{options.base_url}/#{options.tenant_id}"
        end

        options.client_options.authorize_url = "#{base_url}/#{oauth2}/authorize"
        options.client_options.token_url     = "#{base_url}/#{oauth2}/token"

        super
      end

      uid do
        #
        # https://learn.microsoft.com/en-us/entra/identity-platform/migrate-off-email-claim-authorization
        #
        # OID alone might not be unique; TID must be included. An alternative
        # would be to use 'sub' but this is only unique in client/app
        # registration context. If a different app registration is used, the
        # 'sub' values can be different too.
        #
        raw_info['tid'] + raw_info['oid']
      end

      info do
        {
          name:       raw_info['name'],
          email:      raw_info['email'],
          nickname:   raw_info['unique_name'],
          first_name: raw_info['given_name'],
          last_name:  raw_info['family_name']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def callback_url
        full_host + callback_path
      end

      # https://learn.microsoft.com/en-us/entra/identity-platform/id-tokens
      #
      # Some account types from Microsoft seem to only have a decodable ID token,
      # with JWT unable to decode the access token. Information is limited in those
      # cases. Other account types provide an expanded set of data inside the auth
      # token, which does decode as a JWT.
      #
      # Merge the two, allowing the expanded auth token data to overwrite the ID
      # token data if keys collide, and use this as raw info.
      #
      def raw_info
        if @raw_info.nil?
          id_token_data = begin
            ::JWT.decode(access_token.params['id_token'], nil, false).first
          rescue StandardError
            {}
          end

          # For multi-tenant apps (the 'common' tenant_id) it doesn't make any
          # sense to verify the token issuer, because the value of 'iss' in the
          # token depends on the 'tid' in the token itself.
          #
          issuer = options.tenant_id.nil? ? nil : "#{options.base_url}/#{options.tenant_id}/v2.0"

          # https://learn.microsoft.com/en-us/entra/identity-platform/id-tokens#validate-tokens
          #
          JWT::Verify.verify_claims(
            id_token_data,
            verify_iss:        !issuer.nil?,
            iss:               issuer,
            verify_aud:        true,
            aud:               options.client_id,
            verify_expiration: true,
            verify_not_before: true,
            leeway:            options[:jwt_leeway]
          )

          auth_token_data = begin
            ::JWT.decode(access_token.token, nil, false).first
          rescue StandardError
            {}
          end

          id_token_data.merge!(auth_token_data)
          @raw_info = id_token_data
        end

        @raw_info
      end

      # https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#request-an-access-token-with-a-certificate-credential
      #
      # The below methods support the flow for using certificate-based client
      # assertion authentication.
      #
      def client_assertion_type
        'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
      end

      def client_assertion_claims(tenant_id, client_id)
        {
          'aud' => "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token",
          'exp' => Time.now.to_i + 300,
          'iss' => client_id,
          'jti' => SecureRandom.uuid,
          'nbf' => Time.now.to_i,
          'sub' => client_id,
          'iat' => Time.now.to_i
        }
      end

      def client_assertion(tenant_id, client_id, certificate_path)
        certificate_file         = OpenSSL::PKCS12.new(File.read(certificate_path))
        certificate_thumbprint ||= Digest::SHA1.digest(certificate_file.certificate.to_der)
        private_key              = OpenSSL::PKey::RSA.new(certificate_file.key)

        claims = client_assertion_claims(tenant_id, client_id)
        x5c    = Base64.strict_encode64(certificate_file.certificate.to_der)
        x5t    = Base64.strict_encode64(certificate_thumbprint)

        JWT.encode(claims, private_key, 'RS256', { 'x5c': [x5c], 'x5t': x5t })
      end
    end
  end
end
