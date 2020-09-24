# Change Log

## v1.0.0 (2020-09-25)

Remove use of the https://graph.microsoft.com/v1.0/me API …

* One of the key differences for the V2 API vs V1 is the differences
  between who can sign with the addition of Personal Accounts see:
  https://nicolgit.github.io/AzureAD-Endopoint-V1-vs-V2-comparison/

  - In testing found that these accounts may not have access to this
    endpoint
  - All the data provided in `info` exists in the JWT anyway, so this
    cuts down on API calls

* Conform to the Omniauth Auth Hash Schema (1.0 and later) see:
  https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema

  - Expose raw_info
  - Remove `id` from `info`
    - *NB: This could be a breaking change for some however most will
          be using the correct location `uid`*

## v0.1.1 (2020-09-23)

- First release
