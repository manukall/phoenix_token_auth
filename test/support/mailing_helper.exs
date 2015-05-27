defmodule PhoenixTokenAuth.TestMailing do
	@behaviour PhoenixTokenAuth.MailingBehaviour

	def welcome_subject(user), do: "Hello #{user.email}"
	def welcome_body(_user, token), do: token		
	def password_reset_subject(user), do: "Hello #{user.email}"
	def password_reset_body(_user, token), do: token		
	def new_email_address_subject(user), do: "Hello #{user.email}"
	def new_email_address_body(_user, token), do: token		
	
end