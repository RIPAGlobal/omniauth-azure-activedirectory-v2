# AzureAD Example

Example app to provide authentication to Windows Azure Active Directory (WAAD) over OAuth2 using OmniAuth via Devise.

- Rails 7.0
- Bootstrap 5.2
- Devise 4.8
- AzureAD v2 API

## Process

1. Configure app in the [Azure AD Dashboard](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)

    - Get the `client_id`
    - In "Certificates & Secrets", configure a secret. Save the *Value* (not "Secret ID") as `client_secret`
    - [Get your Tenant ID](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant) from "Azure Active Directory > Properties"
    - Add callback URL in "Authentication > Platform configurations > Web > Redirect URIs"
        + `http://localhost:3000/users/auth/azure_activedirectory_v2/callback`

2. Copy `.env-example` to  `.env` and update with the credentials from above.
3. Run `rails db:migrate` from terminal
