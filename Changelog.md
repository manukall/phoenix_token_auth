Changelog
================


## 0.3.0

### Breaking:
Requires phoenix ~> 1.0.0 and ecto ~> 1.0.0.
Make sure your username or email column has a unique index.

## 0.2.2

### Breaking:
Mailer methods now take the connection as additional argument. See `lib/phoenix_token_auth/helpers/mailing_behaviour.ex`.
This allows e.g. accessing headers or adding data from another plug. Thanks to @OpakAlex.
