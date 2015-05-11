defmodule PhoenixTokenAuth.PoisonHelper do
	alias Poison, as: JSON
	@behaviour Joken.Codec

	def encode(map) do
	  JSON.encode!(map)
	end

	def decode(binary) do
	  JSON.decode!(binary, keys: :atoms!)
	end
end