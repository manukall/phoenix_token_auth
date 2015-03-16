defmodule PhoenixTokenAuth.Mailer do
  require Logger

  @moduledoc """
Responsible for sending mails.
Configuration options:

    config :phoenix_token_auth,
      email_sender: "myapp@example.com",
      mailgun_domain: "example.com",
      mailgun_key: "secret"
"""

  use Mailgun.Client, domain: Application.get_env(:phoenix_token_auth, :mailgun_domain),
                      key: Application.get_env(:phoenix_token_auth, :mailgun_key),
                      mode: Application.get_env(:phoenix_token_auth, :mailgun_mode),
                      test_file_path: Application.get_env(:phoenix_token_auth, :mailgun_test_file_path)


  @doc """
  Sends a welcome mail to the user.

  Subject and body can be configured in :phoenix_token_auth, :welcome_email_subject and :welcome_email_body.
  Both config fields have to be functions returning binaries. welcome_email_subject receives the user and
  welcome_email_body the user and confirmation token.
  """
  def send_welcome_email(user, confirmation_token) do
    subject = Application.get_env(:phoenix_token_auth, :welcome_email_subject).(user)
    body = Application.get_env(:phoenix_token_auth, :welcome_email_body).(user, confirmation_token)
    from = Application.get_env(:phoenix_token_auth, :email_sender)

    {:ok, _} = send_email(to: user.email,
               from: from,
               subject: subject,
               text: body)

    Logger.info "Sent welcome email to #{user.email}"
  end

  @doc """
  Sends an email with instructions on how to reset the password to the user.

  Subject and body can be configured in :phoenix_token_auth, :password_reset_email_subject and :password_reset_email_body.
  Both config fields have to be functions returning binaries. password_reset_email_subject receives the user and
  password_reset_email_body the user and reset token.
  """
  def send_password_reset_email(user, reset_token) do
    subject = Application.get_env(:phoenix_token_auth, :password_reset_email_subject).(user)
    body = Application.get_env(:phoenix_token_auth, :password_reset_email_body).(user, reset_token)
    from = Application.get_env(:phoenix_token_auth, :email_sender)

    {:ok, _} = send_email(to: user.email,
               from: from,
               subject: subject,
               text: body)

    Logger.info "Sent password_reset email to #{user.email}"
  end

end
