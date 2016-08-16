defmodule PhoenixTokenAuth.TestMailing do
	@behaviour PhoenixTokenAuth.MailingBehaviour

	def welcome_subject(user, _conn), do: "Hello #{user.email}"
	def welcome_body(_user, _token, conn) do
          language = Plug.Conn.get_req_header(conn, "language")
          "the_emails_body with language #{language}"
        end
	def password_reset_subject(user, _conn), do: "Hello #{user.email}"
	def password_reset_body(_user, _token, _conn), do: "the_emails_body"
	def new_email_address_subject(_user, _conn), do: "Please confirm your email address"
	def new_email_address_body(_user, token, _conn), do: token

end
