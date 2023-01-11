# Change Log

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
