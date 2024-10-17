# Change Log

## v3.0.0 (2024-10-21)

* Branched from `omniauth-entra-id` version 2.4.0 and renamed to `omniauth-entra-id`
* Can specify `tenant_name` in options via #31 (thanks to @Jureamer) for B2C login
* Supports authenticating with a certificate instead of client secret via #32 (thanks to @juliaducey)
* ID token extraction and validation is improved; long-standing fault with UID generation from OIDs (see #33) addressed via #34 (thanks to @tom-brouwer-bex)
