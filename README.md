# OmniAuth::Entra::Id

[![Gem Version](https://badge.fury.io/rb/omniauth-entra-id.svg)](https://rubygems.org/gems/omniauth-entra-id)
[![Build Status](https://github.com/RIPAGlobal/omniauth-entra-id/actions/workflows/master.yml/badge.svg)](https://github.com/RIPAGlobal/omniauth-entra-id/actions)
[![License](https://img.shields.io/github/license/RIPAGlobal/omniauth-entra-id.svg)](LICENSE.txt)

**IMPORTANT: V2 is end-of-life** and superseded by a renamed gem, since Microsoft in their "wisdom" renamed Azure AD to Entra ID. A gem using the old name will become increasingly hard for people to 'discover'. The major version bump provides an opportunity to fix a few things via breaking changes, too. Please switch to `omniauth-entra-id`.

OAuth 2 authentication with [Entra ID API](https://learn.microsoft.com/en-us/entra/identity-platform/v2-overview). Rationale:

* https://github.com/marknadig/omniauth-azure-oauth2 is no longer maintained.
* https://github.com/marknadig/omniauth-azure-oauth2/pull/29 contains important additions.

This gem combines the two and makes some changes to support the Entra API. The old ActiveDirectory V1 API used OpenID Connect. If you need this, a gem from Microsoft [is available here](https://github.com/AzureAD/omniauth-azure-activedirectory), but seems to be abandoned.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-entra-id'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install omniauth-entra-id
```



## Usage

Please start by reading https://github.com/marknadig/omniauth-azure-oauth2 for basic configuration and background information. Note that with this gem, you must use strategy name `entra_id` rather than `azure_oauth2`. Additional configuration information is given below.

### Entra ID server configuration

In most cases, you only want to receive 'verified' email addresses in your application. For older app registrations in the Entra portal, this may need to be [enabled explicitly](https://learn.microsoft.com/en-us/graph/applications-authenticationbehaviors?tabs=http#prevent-the-issuance-of-email-claims-with-unverified-domain-owners). It's [enabled by default](https://learn.microsoft.com/en-us/entra/identity-platform/migrate-off-email-claim-authorization#how-do-i-protect-my-application-immediately) for new multi-tenant app registrations made after June 2023.

### Implementation
#### With `OmniAuth::Builder`

You can do something like this for a static / fixed configuration:

```ruby
use OmniAuth::Builder do
  provider(
    :entra_id,
    {
      client_id:     ENV['ENTRA_CLIENT_ID'],
      client_secret: ENV['ENTRA_CLIENT_SECRET']
    }
  )
end
```

...or, if using a custom provider class (called `YouTenantProvider` in this example):

```ruby
use OmniAuth::Builder do
  provider(
    :entra_id,
    YouTenantProvider
  )
end
```

#### With Devise

In your `config/initializers/devise.rb` file you can do something like this for a static / fixed configuration:

```ruby
config.omniauth(
  :entra_id,
  {
    client_id:     ENV['ENTRA_CLIENT_ID'],
    client_secret: ENV['ENTRA_CLIENT_SECRET']
  }
)
```

...or, if using a custom provider class (called `YouTenantProvider` in this example):

```ruby
config.omniauth(
  :entra_id,
  YouTenantProvider
)
```

### Configuration options

All of the items listed below are optional, unless noted otherwise. They can be provided either in a static configuration Hash as shown in examples above, or via *read accessor instance methods* in a provider class (more on this later).

To have your application authenticate with Entra via a client secret, specify `client_secret`. If you instead want to use certificate-based authentication via client assertion, give the `certificate_path` and `tenant_id` instead. You should provide only `client_secret` or `certificate_path`, not both.

If you're using the client assertion flow, you need to register your certificate in the Entra portal. For more information, please see [the documentation](https://learn.microsoft.com/en-us/entra/identity-platform/certificate-credentials).

| Option | Use |
| ------ | --- |
| `client_id`        | **Mandatory.** Client ID for the 'application' (integration) configured on the Entra side. Found via the Entra UI. |
| `client_secret`    | **Mandatory for client secret flow.** Client secret for the 'application' (integration) configured on the Entra side. Found via the Entra UI. Don't give this if using client assertion flow. |
| `certificate_path` | **Mandatory for client assertion flow.** Don't give this if using a client secret instead of client assertion. This should be the filepath to a PKCS#12 file. |
| `tenant_id`        | **Mandatory for client assertion flow.** Entra Tenant ID for multi-tenanted use. Default is `common`. Forms part of the Entra OAuth URL - `{base}/{tenant_id}/oauth2/v2.0/...` |
| `base_url`         | Location of Entra login page, for specialised requirements; default is `OmniAuth::Strategies::EntraId::BASE_URL` (at the time of writing, this is `https://login.microsoftonline.com`). |
| `tenant_name`      | For what is currently known by its old name of "Azure ActiveDirectory B2C" (and only active if `custom_policy` is also provided - see below), set the tenancy name to constructs the correct B2C endpoint of `{tenant_name}.b2clogin.com/{tenant_name}.onmicrosoft.com/{custom_policy>}" and uses that for auth calls. This is a convenience feature; the `base_entra_url` option could also be manually built up in the same way. |
| `custom_policy`    | Custom policy. Default is nil. Used in conjunction with `tenant_name`- see above. |
| `authorize_params` | Additional parameters passed as URL query data in the initial OAuth redirection to Microsoft. See below for more. Empty Hash default. |
| `domain_hint`      | If defined, sets (overwriting, if already present) `domain_hint` inside `authorize_params`. Default `nil` / none. |
| `scope`            | If defined, sets (overwriting, if already present) `scope` inside `authorize_params`. Default is `OmniAuth::Strategies::EntraId::DEFAULT_SCOPE` (at the time of writing, this is `'openid profile email'`).  |
| `adfs`             | If defined, modifies the URLs so they work with an on premise ADFS server. In order to use this you also need to set the `base_url` correctly and fill the `tenant_id` with `'adfs'`. |

In addition, as a special case, if the request URL contains a query parameter `prompt`, then this will be written into `authorize_params` under that key, overwriting if present any other value there. Note that this comes from the current request URL at the time OAuth flow is commencing, _not_ via static options Hash data or via a custom provider class - but you _could_ just as easily set `scope` inside a custom `authorize_params` returned from a provider class, as shown in an example later; the request URL query mechanism is just another way of doing the same thing.

#### Explaining `custom_policy` and `tenant_name`

When using Azure ActiveDirectory B2C - which seems to be distinct from Entra ID and not renamed as of October 2024 - tenants can define custom policies. With normal OAuth use cases, when the underlying `oauth2` gem creates the request for getting a token via POST, it places all `params` (which would include anything you've provided in the normal configuration to name your custom policy) in the `body` of the request. This would not work. Microsoft's documentation indicates that when [requesting a token](https://learn.microsoft.com/en-us/azure/active-directory-b2c/access-tokens#request-a-token), they want the name of custom policies to be given in the URL rather than in the body of the request. They ignore a custom policy specified in the body.

Solve this for B2C use cases by giving your tenant name and custom policy name in the relevant configuration options. This causes a base URL to be constructed as follows:

```
<tenant-name>.b2clogin.com/<tenant-name>.onmicrosoft.com/<policy-name>/oauth2/v2.0/...
```

#### Explaining `authorize_params`

The `authorize_params` hash-like object contains key-value pairs which are transformed into URL query string data and added to existing standard OAuth query data in the URL used for the initial redirection from your web site, to the Microsoft Entra login page, at the start of OAuth flow. You can find these listed some way down the table just below an OAuth URL example at:

* https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#request-an-authorization-code

...looking for in particular items from `prompt` onwards.

#### Dynamic options via a custom provider class

Documentation mentioned earlier at https://github.com/marknadig/omniauth-azure-oauth2#usage gives an example of setting tenant ID dynamically via a custom provider class. We can also use that class in other ways. For example, let's rewrite it thus:

```ruby
class YouTenantProvider
  def initialize(strategy)
    @strategy = strategy
  end

  def client_id
    ENV['ENTRA_CLIENT_ID']
  end

  def client_secret
    ENV['ENTRA_CLIENT_SECRET']
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

In this example, we're providing custom `authorize_params`. You can just return a standard Ruby Hash here, using lower case String or Symbol keys. The `strategy` value given to the initializer is an instance of [`OmniAuth::Strategies::EntraId`](https://github.com/RIPAGlobal/omniauth-entra-id/blob/master/lib/omniauth/strategies/entra_id.rb) which is a subclass of [`OmniAuth::Strategies::OAuth2`](https://www.rubydoc.info/gems/omniauth-oauth2/1.8.0/OmniAuth/Strategies/OAuth2), but that's not all that helpful! What's more useful is to know that **the Rails `request` object is available via `@strategy.request` and, likewise, the session store via `@strategy.session`**. This gives you a lot of flexibility for responding to an inbound request or user session, varying the parameters used for the Entra OAuth flow.

In method `#authorize_params` above, the request object is used to look for a `login_hint` query string entry, set in whichever view(s) is/are presented by your application for use when your users need to be redirected to the OmniAuth controller in order to kick off OAuth with Entra. The value is copied into the `authorize_params` Hash. Earlier, it was mentioned that there was a special case of `prompt` being pulled from the request URL query data, but that this could also be done via a custom provider - here, you can see how; just check `@strategy.request.params['prompt']` and copy that into `authorize_params` if preset.

> **NB:** Naming things is hard! The predecessor gem used the name `YouTenantProvider` since it was focused on custom tenant provision, but if using this in a more generic way, perhaps consider a more generic name such as, say, `CustomOmniAuthEntraProvider`.

#### Special case scope override

If required and more convenient, you can specify a custom `scope` value via generation of an authorisation URL including that required `scope`, rather than by using a custom provider class with `def scope...end` method. Include the `scope` value in your call to generate the URL thus:

```ruby
omniauth_authorize_url('resource_name_eg_user', 'entra_id', scope: '...')
```



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RIPAGlobal/omniauth-entra-id. This project is intended to be a safe, welcoming space for collaboration so contributors must adhere to the [code of conduct](https://github.com/RIPAGlobal/omniauth-entra-id/blob/master/CODE_OF_CONDUCT.md).

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

Everyone interacting in this project's codebases, issue trackers, chat rooms and mailing lists must follow the [code of conduct](https://github.com/RIPAGlobal/omniauth-entra-id/blob/master/CODE_OF_CONDUCT.md).
