# OmniAuth::Azure::Activedirectory::V2

[![Gem Version](https://badge.fury.io/rb/omniauth-azure-activedirectory-v2.svg)](https://rubygems.org/gems/omniauth-azure-activedirectory-v2)
[![Build Status](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/actions/workflows/master.yml/badge.svg)](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/actions)
[![License](https://img.shields.io/github/license/RIPAGlobal/omniauth-azure-activedirectory-v2.svg)](LICENSE.txt)

**IMPORTANT: V2 is end-of-life** and superseded by a renamed gem, since Microsoft in their "wisdom" renamed Azure AD to Entra ID. A gem using the old name will become increasingly hard for people to 'discover'. The major version bump provides an opportunity to fix a few things via breaking changes, too. Please switch to `omniauth-entra-id`.

OAuth 2 authentication with [Azure ActiveDirectory's V2 API](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview). Rationale:

* https://github.com/marknadig/omniauth-azure-oauth2 is no longer maintained.
* https://github.com/marknadig/omniauth-azure-oauth2/pull/29 contains important additions.

This gem combines the two and makes some changes to support the full V2 API.

The ActiveDirectory V1 auth API used OpenID Connect. If you need this, a gem from Microsoft [is available here](https://github.com/AzureAD/omniauth-azure-activedirectory), but seems to be abandoned.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-azure-activedirectory-v2'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install omniauth-azure-activedirectory-v2
```


## Usage

Please start by reading https://github.com/marknadig/omniauth-azure-oauth2 for basic configuration and background information. Note that with this gem, you must use strategy name `azure_activedirectory_v2` rather than `azure_oauth2`. Additional configuration information is given below.

### Entra ID Configuration
In most cases, you only want to receive 'verified' email addresses in
your application. For older app registrations in the Azure portal,
this may need to be [enabled explicitly](https://learn.microsoft.com/en-us/graph/applications-authenticationbehaviors?tabs=http#prevent-the-issuance-of-email-claims-with-unverified-domain-owners).

It's [enabled by default](https://learn.microsoft.com/en-us/entra/identity-platform/migrate-off-email-claim-authorization#how-do-i-protect-my-application-immediately)
for new multi-tenant app registrations made after June 2023.

### Implementation

#### With `OmniAuth::Builder`

You can do something like this for a static / fixed configuration:

```ruby
use OmniAuth::Builder do
  provider(
    :azure_activedirectory_v2,
    {
      client_id:     ENV['AZURE_CLIENT_ID'],
      client_secret: ENV['AZURE_CLIENT_SECRET']
    }
  )
end
```

...or, if using a custom provider class (called `YouTenantProvider` in this example):

```ruby
use OmniAuth::Builder do
  provider(
    :azure_activedirectory_v2,
    YouTenantProvider
  )
end
```

#### With Devise

In your `config/initializers/devise.rb` file you can do something like this for a static / fixed configuration:

```ruby
config.omniauth(
  :azure_activedirectory_v2,
  {
    client_id:     ENV['AZURE_CLIENT_ID'],
    client_secret: ENV['AZURE_CLIENT_SECRET']
  }
)
```

...or, if using a custom provider class (called `YouTenantProvider` in this example):

```ruby
config.omniauth(
  :azure_activedirectory_v2,
  YouTenantProvider
)
```

### Configuration options

All of the items listed below are optional, unless noted otherwise. They can be provided either in a static configuration Hash as shown in examples above, or via *read accessor instance methods* in a provider class (more on this later).

To have your application authenticate with Entra (formerly known as AAD) via client secret, specify client_secret. If you instead want to use certificate-based authentication via client assertion, give the certificate_path and tenant_id instead. You should provide only client_secret or certificate_path, not both.

If you're using the client assertion flow, you need to register your certificate in the Azure portal. For more information, please see [the documentation](https://learn.microsoft.com/en-us/entra/identity-platform/certificate-credentials).

| Option             | Use                                                                                                                                                                                                                         |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `client_id`        | **Mandatory.** Client ID for the 'application' (integration) configured on the Azure side. Found via the Azure UI.                                                                                                          |
| `client_secret`    | **Mandatory for client secret flow.** Client secret for the 'application' (integration) configured on the Azure side. Found via the Azure UI. Don't give this if using client assertion flow.                               |
| `certificate_path` | **Mandatory for client assertion flow.** Don't give this if using a client secret instead of client assertion. This should be the filepath to a PKCS#12 file.                                                               |
| `base_azure_url`   | Location of Azure login page, for specialised requirements; default is `OmniAuth::Strategies::AzureActivedirectoryV2::BASE_AZURE_URL` (at the time of writing, this is `https://login.microsoftonline.com`).                |
| `tenant_id`        | **Mandatory for client assertion flow.** _Azure_ tenant ID for multi-tenanted use. Default is `common`. Forms part of the Azure OAuth URL - `{base}/{tenant_id}/oauth2/v2.0/...`                                            |
| `custom_policy`    | _Azure_ custom policy. Default is nil. Forms part of the Azure Token URL - `{base}/{tenant_id}/{custom_policy}/oauth2/v2.0/...`                                                                                             |
| `authorize_params` | Additional parameters passed as URL query data in the initial OAuth redirection to Microsoft. See below for more. Empty Hash default.                                                                                       |
| `domain_hint`      | If defined, sets (overwriting, if already present) `domain_hint` inside `authorize_params`. Default `nil` / none.                                                                                                           |
| `scope`            | If defined, sets (overwriting, if already present) `scope` inside `authorize_params`. Default is `OmniAuth::Strategies::AzureActivedirectoryV2::DEFAULT_SCOPE` (at the time of writing, this is `'openid profile email'`).  |
| `adfs`             | If defined, modifies the URLs so they work with an on premise ADFS server. In order to use this you also need to set the `base_azure_url` correctly and fill the `tenant_id` with `'adfs'`.                                 |

In addition, as a special case, if the request URL contains a query parameter `prompt`, then this will be written into `authorize_params` under that key, overwriting if present any other value there. Note that this comes from the current request URL at the time OAuth flow is commencing, _not_ via static options Hash data or via a custom provider class - but you _could_ just as easily set `scope` inside a custom `authorize_params` returned from a provider class, as shown in an example later; the request URL query mechanism is just another way of doing the same thing.

#### Explaining `custom_policy`

In the documentation for [requesting a token](https://learn.microsoft.com/en-us/azure/active-directory-b2c/access-tokens#request-a-token), Microsoft indicate that they want the name of custom policies to be given in the URL rather than in the body of the request:

```
POST <tenant-name>.b2clogin.com/<tenant-name>.onmicrosoft.com/<policy-name>/oauth2/v2.0/token
```

When the underlying `oath2` gem creates the request for getting a token via POST, it places all `params` (which would include anything you've provided in the normal configuration to name your custom policy) in the `body` of the request. Unfortunately, Microsoft ignores custom policies in the body and only looks for them in the URL.

If you set a `custom_policy` in your configuration, it will be included in the URL between the `tenant_id` and the remaining parts of the path (`/oauth2/v2.0/token`).

#### Explaining `authorize_params`

The `authorize_params` hash-like object contains key-value pairs which are transformed into URL query string data and added to existing standard OAuth query data in the URL used for the initial redirection from your web site, to the Microsoft Azure AD login page, at the start of OAuth flow. You can find these listed some way down the table just below an OAuth URL example at:

* https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow#code-try-1

...looking for in particular items from `prompt` onwards.

#### Dynamic options via a custom provider class

Documentation mentioned earlier at https://github.com/marknadig/omniauth-azure-oauth2#usage gives an example of setting tenant ID dynamically via a custom provider class. We can also use that class in other ways. For example, let's rewrite it thus:

```ruby
class YouTenantProvider
  def initialize(strategy)
    @strategy = strategy
  end

  def client_id
    ENV['AZURE_CLIENT_ID']
  end

  def client_secret
    ENV['AZURE_CLIENT_SECRET']
  end

  def authorize_params
    ap = {}

    if @strategy.request && @strategy.request.params['login_hint']
      ap['login_hint'] = @strategy.request.params['login_hint']
    end

    return ap
  end
end
```

In this example, we're providing custom `authorize_params`. You can just return a standard Ruby Hash here, using lower case String or Symbol keys. The `strategy` value given to the initializer is an instance of [`OmniAuth::StrategiesAzureActivedirectoryV2`](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/blob/master/lib/omniauth/strategies/azure_activedirectory_v2.rb) which is a subclass of [`OmniAuth::Strategies::OAuth2`](https://www.rubydoc.info/gems/omniauth-oauth2/1.8.0/OmniAuth/Strategies/OAuth2), but that's not all that helpful! What's more useful is to know that **the Rails `request` object is available via `@strategy.request` and, likewise, the session store via `@strategy.session`**. This gives you a lot of flexibility for responding to an inbound request or user session, varying the parameters used for the Azure OAuth flow.

In method `#authorize_params` above, the request object is used to look for a `login_hint` query string entry, set in whichever view(s) is/are presented by your application for use when your users need to be redirected to the OmniAuth controller in order to kick off OAuth with Azure. The value is copied into the `authorize_params` Hash. Earlier, it was mentioned that there was a special case of `prompt` being pulled from the request URL query data, but that this could also be done via a custom provider - here, you can see how; just check `@strategy.request.params['prompt']` and copy that into `authorize_params` if preset.

> **NB:** Naming things is hard! The predecessor gem used the name `YouTenantProvider` since it was focused on custom tenant provision, but if using this in a more generic way, perhaps consider a more generic name such as, say, `CustomOmniAuthAzureProvider`.

#### Special case scope override

If required and more convenient, you can specify a custom `scope` value via generation of an authorisation URL including that required `scope`, rather than by using a custom provider class with `def scope...end` method. Include the `scope` value in your call to generate the URL thus:

```ruby
omniauth_authorize_url('resource_name_eg_user', 'azure_activedirectory_v2', scope: '...')
```



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2. This project is intended to be a safe, welcoming space for collaboration so contributors must adhere to the [code of conduct](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/blob/master/CODE_OF_CONDUCT.md).

### Getting running

* Fork the repository
* Check out your fork
* `cd` into the repository
* `bin/setup`
* `bundle exec rspec` to make sure all the tests run

### Making changes

* Make your change
* Add tests and check that `bundle exec rspec` still runs successfully
* For new features (rather than bug fixes), update `README.md` with details



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).



## Code of Conduct

Everyone interacting in this project's codebases, issue trackers, chat rooms and mailing lists must follow the [code of conduct](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/blob/master/CODE_OF_CONDUCT.md).
