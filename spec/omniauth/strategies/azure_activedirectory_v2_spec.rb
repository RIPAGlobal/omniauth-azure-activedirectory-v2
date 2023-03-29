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
    end
  end

  describe 'raw_info' do
    subject do
      OmniAuth::Strategies::AzureActivedirectoryV2.new(app, {client_id: 'id', client_secret: 'secret'})
    end

    let(:id_token_info) do
      {
        oid:         'my_id',
        name:        'Bob Doe',
        email:       'bob@doe.com',
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
        expect(subject.uid).to eq('my_id')
      end
    end # "context 'with information only in the ID token' do"

    context 'with extra information in the auth token' do
      let(:auth_token_info) do
        {
          oid:         'overridden_id',
          email:       'bob@doe.com',
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
        expect(subject.uid).to eq('overridden_id')
      end
    end # "context 'with extra information in the auth token' do"
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
