defmodule PhoenixTokenAuth.Mailer do
  require Logger

  use Mailgun.Client, domain: Application.get_env(:phoenix_token_auth, :mailgun_domain),
                      key: Application.get_env(:phoenix_token_auth, :mailgun_key),
                      mode: Application.get_env(:phoenix_token_auth, :mailgun_mode),
                      test_file_path: Application.get_env(:phoenix_token_auth, :mailgun_test_file_path)


  @from Application.get_env(:phoenix_token_auth, :email_sender)

  def send_welcome_email(user, confirmation_token) do
    subject = Application.get_env(:phoenix_token_auth, :welcome_email_subject).(user)
    body = Application.get_env(:phoenix_token_auth, :welcome_email_body).(user, confirmation_token)

    {:ok, _} = send_email(to: user.email,
               from: @from,
               subject: subject,
               text: body)

    Logger.info "Sent welcome email to #{user.email}"
  end

end
