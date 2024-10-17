require 'spec_helper'
require 'omniauth/azure_activedirectory_v2'

RSpec.describe OmniAuth::Strategies::AzureActivedirectoryV2 do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}) }
  let(:app) {
    lambda do
      [200, {}, ["Hello."]]
    end
  }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe 'static configuration' do
    let(:options) { @options || {} }
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret', tenant_id: 'tenant'}.merge(options))
    end

    describe '#client' do
      it 'has correct authorize url' do
        allow(subject).to receive(:request) { request }
        expect(subject.client.options[:authorize_url]).to eql('https://login.microsoftonline.com/tenant/oauth2/v2.0/authorize')
      end

      it 'has correct authorize params' do
        allow(subject).to receive(:request) { request }
        subject.client
        expect(subject.authorize_params[:domain_hint]).to be_nil
      end

      it 'has correct token url' do
        allow(subject).to receive(:request) { request }
        expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.com/tenant/oauth2/v2.0/token')
      end

      context 'when a custom policy is present' do
        it 'includes custom policy in token url' do
          @options = { custom_policy: 'my_policy' }
          allow(subject).to receive(:request) { request }
          expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.com/tenant/my_policy/oauth2/v2.0/token')
        end
      end

      it 'supports authorization_params' do
        @options = { authorize_params: {prompt: 'select_account'} }
        allow(subject).to receive(:request) { request }
        subject.client
        expect(subject.authorize_params[:prompt]).to eql('select_account')
      end

      describe "overrides" do
        it 'should override domain_hint' do
          @options = {domain_hint: 'hint'}
          allow(subject).to receive(:request) { request }
          subject.client
          expect(subject.authorize_params[:domain_hint]).to eql('hint')
        end

        it 'overrides prompt via query parameter' do
          @options = { authorize_params: {prompt: 'select_account'} }
          override_request = double('Request', :params => {'prompt'.to_s => 'consent'}, :cookies => {}, :env => {})
          allow(subject).to receive(:request) { override_request }
          subject.client
          expect(subject.authorize_params[:prompt]).to eql('consent')
        end
      end
    end

  end

  describe 'static configuration - german' do
    let(:options) { @options || {} }
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret', tenant_id: 'tenant', base_azure_url: 'https://login.microsoftonline.de'}.merge(options))
    end

    describe '#client' do
      it 'has correct authorize url' do
        allow(subject).to receive(:request) { request }
        expect(subject.client.options[:authorize_url]).to eql('https://login.microsoftonline.de/tenant/oauth2/v2.0/authorize')
      end

      it 'has correct authorize params' do
        allow(subject).to receive(:request) { request }
        subject.client
        expect(subject.authorize_params[:domain_hint]).to be_nil
      end

      it 'has correct token url' do
        allow(subject).to receive(:request) { request }
        expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.de/tenant/oauth2/v2.0/token')
      end

      it 'has correct authorize_params' do
        allow(subject).to receive(:request) { request }
        subject.client
        expect(subject.authorize_params[:scope]).to eql('openid profile email')
      end

      describe "overrides" do
        it 'should override domain_hint' do
          @options = {domain_hint: 'hint'}
          allow(subject).to receive(:request) { request }
          subject.client
          expect(subject.authorize_params[:domain_hint]).to eql('hint')
        end
      end
    end
  end

  describe 'static common configuration' do
    let(:options) { @options || {} }
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret'}.merge(options))
    end

    before do
      allow(subject).to receive(:request) { request }
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.microsoftonline.com/common/oauth2/v2.0/authorize')
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.com/common/oauth2/v2.0/token')
      end
    end
  end

  describe 'static configuration with on premise ADFS' do
    let(:options) { @options || {} }
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret', tenant_id: 'adfs', base_azure_url: 'https://login.contoso.com', adfs: true}.merge(options))
    end

    describe '#client' do
      it 'has correct authorize url' do
        allow(subject).to receive(:request) { request }
        expect(subject.client.options[:authorize_url]).to eql('https://login.contoso.com/adfs/oauth2/authorize')
      end

      it 'has correct token url' do
        allow(subject).to receive(:request) { request }
        expect(subject.client.options[:token_url]).to eql('https://login.contoso.com/adfs/oauth2/token')
      end
    end
  end

  describe 'dynamic configuration' do
    let(:provider_klass) {
      Class.new {
        def initialize(strategy)
        end

        def client_id
          'id'
        end

        def client_secret
          'secret'
        end

        def tenant_id
          'tenant'
        end

        def authorize_params
          { custom_option: 'value' }
        end
      }
    }

    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, provider_klass)
    end

    before do
      allow(subject).to receive(:request) { request }
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.microsoftonline.com/tenant/oauth2/v2.0/authorize')
      end

      it 'has correct authorize params' do
        subject.client
        expect(subject.authorize_params[:domain_hint]).to be_nil
        expect(subject.authorize_params[:custom_option]).to eql('value')
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.com/tenant/oauth2/v2.0/token')
      end

      it 'has correct authorize_params' do
        subject.client
        expect(subject.authorize_params[:scope]).to eql('openid profile email')
      end

      # todo: how to get this working?
      # describe "overrides" do
      #   it 'should override domain_hint' do
      #     provider_klass.domain_hint = 'hint'
      #     subject.client
      #     expect(subject.authorize_params[:domain_hint]).to eql('hint')
      #   end
      # end
    end

  end

  describe 'dynamic configuration - german' do
    let(:provider_klass) {
      Class.new {
        def initialize(strategy)
        end

        def client_id
          'id'
        end

        def client_secret
          'secret'
        end

        def tenant_id
          'tenant'
        end

        def base_azure_url
          'https://login.microsoftonline.de'
        end

        def scope
          'Calendars.ReadWrite email offline_access User.Read'
        end
      }
    }

    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, provider_klass)
    end

    before do
      allow(subject).to receive(:request) { request }
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.microsoftonline.de/tenant/oauth2/v2.0/authorize')
      end

      it 'has correct authorize params' do
        subject.client
        expect(subject.authorize_params[:domain_hint]).to be_nil
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.de/tenant/oauth2/v2.0/token')
      end

      it 'has correct scope' do
        subject.client
        expect(subject.authorize_params[:scope]).to eql('Calendars.ReadWrite email offline_access User.Read')
      end

      # todo: how to get this working?
      # describe "overrides" do
      #   it 'should override domain_hint' do
      #     provider_klass.domain_hint = 'hint'
      #     subject.client
      #     expect(subject.authorize_params[:domain_hint]).to eql('hint')
      #   end
      # end
    end

  end

  describe 'dynamic common configuration' do
    let(:provider_klass) {
      Class.new {
        def initialize(strategy)
        end

        def client_id
          'id'
        end

        def client_secret
          'secret'
        end
      }
    }

    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, provider_klass)
    end

    before do
      allow(subject).to receive(:request) { request }
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.microsoftonline.com/common/oauth2/v2.0/authorize')
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.microsoftonline.com/common/oauth2/v2.0/token')
      end

      it 'has correct scope from request params' do
        request.params['scope'] = 'openid email offline_access Calendars.Read'
        subject.client
        expect(subject.authorize_params[:scope]).to eql('openid email offline_access Calendars.Read')
      end
    end
  end

  describe 'dynamic configuration with on premise ADFS' do
    let(:provider_klass) {
      Class.new {
        def initialize(strategy)
        end

        def client_id
          'id'
        end

        def client_secret
          'secret'
        end

        def tenant_id
          'adfs'
        end

        def base_azure_url
          'https://login.contoso.com'
        end

        def adfs?
          true
        end
      }
    }

    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, provider_klass)
    end

    before do
      allow(subject).to receive(:request) { request }
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.contoso.com/adfs/oauth2/authorize')
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.contoso.com/adfs/oauth2/token')
      end
    end
  end

  describe 'raw_info' do
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret'})
    end

    let(:id_token_info) do
      issued_at = Time.now.utc.to_i
      expires_at = (Time.now + 3600).to_i
      {
        ver: '2.0',
        iss: 'https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0',
        sub: 'sdfkjllAkdkWkeiidkcXKfjjsl',
        aud: 'id',
        exp: expires_at,
        iat: issued_at,
        nbf: issued_at,
        name: 'Bob Doe',
        preferred_username: 'bob@doe.com',
        oid: 'my_id',
        email: 'bob@doe.com',
        tid: '9188040d-6c67-4c5b-b112-36a304b66dad',
        aio: 'KSslldiwDkfjjsoeiruosKD',
        unique_name: 'bobby'
      }
    end

    let(:id_token) do
      JWT.encode(id_token_info, 'secret')
    end

    let(:access_token) do
      double(:token => SecureRandom.uuid, :params => {'id_token' => id_token})
    end

    before do
      allow(subject).to receive(:access_token) { access_token }
      allow(subject).to receive(:request)      { request      }
    end

    context 'with information only in the ID token' do
      it 'returns correct info' do
        expect(subject.info).to eq({
                                     name:      'Bob Doe',
                                     email:     'bob@doe.com',
                                     nickname:  'bobby',
                                     first_name: nil,
                                     last_name:  nil
                                   })
      end

      it 'returns correct uid' do
        expect(subject.uid).to eq('9188040d-6c67-4c5b-b112-36a304b66dadmy_id')
      end
    end # "context 'with information only in the ID token' do"

    context 'with extra information in the auth token' do
      let(:auth_token_info) do
        issued_at = Time.now.utc.to_i
        expires_at = (Time.now + 3600).to_i
        {
          ver: '2.0',
          iss: 'https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0',
          sub: 'sdfkjllAkdkWkeiidkcXKfjjsl',
          aud: 'id',
          exp: expires_at,
          iat: issued_at,
          nbf: issued_at,
          preferred_username: 'bob@doe.com',
          oid: 'overridden_id',
          email: 'bob@doe.com',
          tid: '9188040d-6c67-4c5b-b112-36a304b66dad',
          aio: 'KSslldiwDkfjjsoeiruosKD',
          unique_name: 'Bobby Definitely Doe',
          given_name:  'Bob',
          family_name: 'Doe'
        }
      end

      let(:auth_token) do
        JWT.encode(auth_token_info, 'secret')
      end

      let(:access_token) do
        double(:token => auth_token, :params => {'id_token' => id_token})
      end

      it 'returns correct info' do
        expect(subject.info).to eq({
                                     name:       'Bob Doe',
                                     email:      'bob@doe.com',
                                     nickname:   'Bobby Definitely Doe',
                                     first_name: 'Bob',
                                     last_name:  'Doe'
                                   })
      end

      it 'returns correct uid' do
        expect(subject.uid).to eq('9188040d-6c67-4c5b-b112-36a304b66dadoverridden_id')
      end
    end # "context 'with extra information in the auth token' do"

    context 'with an invalid audience' do
      let(:id_token_info) do
        issued_at = Time.now.utc.to_i
        expires_at = (Time.now + 3600).to_i
        {
          ver: '2.0',
          iss: 'https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0',
          sub: 'sdfkjllAkdkWkeiidkcXKfjjsl',
          aud: 'other-id',
          exp: expires_at,
          iat: issued_at,
          nbf: issued_at,
          name: 'Bob Doe',
          preferred_username: 'bob@doe.com',
          oid: 'my_id',
          email: 'bob@doe.com',
          tid: '9188040d-6c67-4c5b-b112-36a304b66dad',
          aio: 'KSslldiwDkfjjsoeiruosKD',
          unique_name: 'bobby'
        }
      end

      it 'fails validation' do
        expect { subject.info }.to raise_error(JWT::InvalidAudError)
      end
    end

    context 'with an invalid issuer' do
      subject do
        OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret', tenant_id: 'test-tenant'})
      end

      it 'fails validation' do
        expect { subject.info }.to raise_error(JWT::InvalidIssuerError)
      end
    end

    context 'with an invalid not_before' do
      let(:id_token_info) do
        issued_at = (Time.now + 70).to_i # Since leeway is 60 seconds
        expires_at = (Time.now + 3600).to_i
        {
          ver: '2.0',
          iss: 'https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0',
          sub: 'sdfkjllAkdkWkeiidkcXKfjjsl',
          aud: 'id',
          exp: expires_at,
          iat: issued_at,
          nbf: issued_at,
          name: 'Bob Doe',
          preferred_username: 'bob@doe.com',
          oid: 'my_id',
          email: 'bob@doe.com',
          tid: '9188040d-6c67-4c5b-b112-36a304b66dad',
          aio: 'KSslldiwDkfjjsoeiruosKD',
          unique_name: 'bobby'
        }
      end

      it 'fails validation' do
        expect { subject.info }.to raise_error(JWT::ImmatureSignature)
      end
    end

    context 'with an expired token' do
      let(:id_token_info) do
        issued_at = (Time.now - 3600).to_i
        expires_at = (Time.now - 70).to_i # Since leeway is 60 seconds
        {
          ver: '2.0',
          iss: 'https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0',
          sub: 'sdfkjllAkdkWkeiidkcXKfjjsl',
          aud: 'id',
          exp: expires_at,
          iat: issued_at,
          nbf: issued_at,
          name: 'Bob Doe',
          preferred_username: 'bob@doe.com',
          oid: 'my_id',
          email: 'bob@doe.com',
          tid: '9188040d-6c67-4c5b-b112-36a304b66dad',
          aio: 'KSslldiwDkfjjsoeiruosKD',
          unique_name: 'bobby'
        }
      end

      it 'fails validation' do
        expect { subject.info }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end   # "describe 'raw_info' do"

  describe 'callback_url' do
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, { client_id: 'id', client_secret: 'secret', tenant_id: 'tenant' })
    end

    let(:base_url) { 'https://example.com' }

    it 'has the correct default callback path' do
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name) { '' }
      expect(subject.callback_url).to eq(base_url + '/auth/azure_activedirectory_v2/callback')
    end

    it 'should set the callback path with script_name if present' do
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name) { '/v1' }
      expect(subject.callback_url).to eq(base_url + '/v1/auth/azure_activedirectory_v2/callback')
    end
  end
end
