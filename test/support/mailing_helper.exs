defmodule PhoenixTokenAuth.TestMailing do
	@behaviour PhoenixTokenAuth.MailingBehaviour

	def welcome_subject(user), do: "Hello #{user.email}"
	def welcome_body(_user, _token), do: "the_emails_body" 		
	def password_reset_subject(user), do: "Hello #{user.email}"
	def password_reset_body(_user, _token), do: "the_emails_body" 		
	def new_email_address_subject(_user), do: "Please confirm your email address"
	def new_email_address_body(_user, token), do: token
	
end