Changelog
================


## 0.2.2

### Breaking:
Mailer methods now take the connection as additional argument. See `lib/phoenix_token_auth/helpers/mailing_behaviour.ex`.
This allows e.g. accessing headers or adding data from another plug. Thanks to @OpakAlex.
