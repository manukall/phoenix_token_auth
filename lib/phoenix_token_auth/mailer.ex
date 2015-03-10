defmodule PhoenixTokenAuth.Mailer do
  use Mailgun.Client, domain: Application.get_env(:phoenix_token_auth, :mailgun_domain),
                      key: Application.get_env(:phoenix_token_auth, :mailgun_key)

  @from Application.get_env(:phoenix_token_auth, :email_sender)

  def send_welcome_email(user, confirmation_token) do
    subject = Application.get_env(:phoenix_token_auth, :welcome_email_subject).(user)
    body = Application.get_env(:phoenix_token_auth, :welcome_email_body).(user, confirmation_token)

    send_email to: user.email,
               from: @from,
               subject: subject,
               body: body
  end

end
