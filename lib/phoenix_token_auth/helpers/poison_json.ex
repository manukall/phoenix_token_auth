defmodule PhoenixTokenAuth.PoisonHelper do
	alias Poison, as: JSON
	@behaviour Joken.Codec

	def encode(map) do
	  JSON.encode!(map)
	end

	def decode(binary) do
    ensure_atoms_exist
    # will raise an argument error if the atoms do not exist yet
	  JSON.decode!(binary, keys: :atoms!)
	end

  defp ensure_atoms_exist do
    :token_id
  end
end
