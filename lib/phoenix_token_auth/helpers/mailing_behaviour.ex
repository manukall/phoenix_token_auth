defmodule PhoenixTokenAuth.MailingBehaviour do
	use Behaviour

	@doc """
	Function returning the subject of a welcome email for the given
	user and connection struct.
	"""
	defcallback  welcome_subject(any, Map.t) ::  String.t

	@doc """
	Function returning the body of a welcome email. Parameters are:
	the User struct, confirmation token and connection struct.
	"""
	defcallback welcome_body(any, String.t, Map.t) :: String.t

	@doc """
	Function returning the subject of a password reset email for the given
	user and connection struct.
	"""
	defcallback password_reset_subject(any, Map.t) :: String.t

	@doc """
	Function returning the body of a password reset email. Parameters are:
	the User struct, reset token and connection struct.
	"""
	defcallback password_reset_body(any, String.t, Map.t) :: String.t

	@doc """
	Function returning the subject of a new email-address email for the given
	user and connection struct.
	"""
	defcallback new_email_address_subject(any, Map.t) :: String.t

	@doc """
	Function returning the body of a new email-address email. Parameters are:
	the User struct, reset token and connection struct.
	"""
	defcallback new_email_address_body(any, String.t, Map.t) :: String.t


end
