# Change Log

## v2.4.0 (2024-10-17)

Deprecation warnings for end-of-life of the gem under this name. No other changes. The GitHub repository is to be renamed and the gem released (starting at major version 3) as `omniauth-entra-id`, with some breaking changes but details of how to update will be provided in the new gem via an `UPGRADING.md` document.

## v2.3.0 (2024-07-16)

[Implements](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/pull/29) support for on-premise Active Directory installations via the `adfs` option; see `README.md` for details - thanks @frenkel!

## v2.2.0 (2024-07-09)

[Implements](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/pull/26) support for specifying `scope` via the authorisation URL, in addition to the prior support for static configuration or configuration via a custom provider class - thanks @nbgoodall!

## v2.1.0 (2023-09-16)

[Implements](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/pull/19) support for custom policies when using Microsoft Azure AD - thanks @stevenchanin!

## v2.0.2 (2023-03-31)

[Fixes](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/pull/16) inability to override prompt in authorisation parameters - thanks @lamroger!

## v2.0.1 (2023-01-11)

Renames:

* RIPGlobal -> RIPAGlobal
* Omniauth -> OmniAuth

_No functional change._

## v2.0.0 (2022-09-14)

Makes compatible with OmniAuth 2 and requires it.

Note: https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/pull/6 for reasoning - Thanks @jessieay

_Major version bump as no longer supports OmniAuth 1._

## v1.0.0 (2020-09-25)

Removes use of the https://graph.microsoft.com/v1.0/me API.

* One of the key differences for the V2 API vs V1 is the differences
  between who can sign with the addition of Personal Accounts - see:
  https://nicolgit.github.io/AzureAD-Endopoint-V1-vs-V2-comparison/

  - In testing we found that these accounts may not have access to
    this endpoint
  - All the data provided in `info` exists in the JWT anyway, so this
    cuts down on API calls

* Conforms to the OmniAuth Auth Hash Schema (1.0 and later) - see:
  https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema

  - Expose `raw_info`
  - Remove `id` from `info`
    - *NB: This could be a breaking change for some, but most will
           already be using the correct property name of `uid`.*

## v0.1.1 (2020-09-23)

- First release.
