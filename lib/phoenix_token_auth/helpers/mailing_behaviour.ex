defmodule PhoenixTokenAuth.MailingBehaviour do
	use Behaviour

	@doc """
	Function returning the subject of a welcome email for the given
	user. 
	"""
	defcallback  welcome_subject(any) ::  String.t

	@doc """
	Function returning the body of a welcome email. Parameter is 
	the User struct and the confirmation token. 
	"""
	defcallback welcome_body(any, String.t) :: String.t

	@doc """
	Function returning the subject of a password reset email for the given
	user. 
	"""
	defcallback password_reset_subject(any) :: String.t 

	@doc """
	Function returning the body of a password reset email. Parameter is 
	the User struct and the reset token. 
	"""
	defcallback password_reset_body(any, String.t) :: String.t

	@doc """
	Function returning the subject of a new email-address email for the given
	user. 
	"""
	defcallback new_email_address_subject(any) :: String.t 

	@doc """
	Function returning the body of a new email-address email. Parameter is 
	the User struct and the reset token. 
	"""
	defcallback new_email_address_body(any, String.t) :: String.t


end