defmodule BitMsg.ChatRooms.Message do
  alias __MODULE__
  
  @sha256_to_rsa_length 172

  @enforce_keys [:body, :signature, :sender, :recipient]
  defstruct @enforce_keys

  @doc """
    Helper function for checking that the signature of a message
    could have came from an encryption of a sha hash of the body.
  """
  def test_signature(%Message{signature: signature}) do
    len = signature |> String.length

    len == @sha256_to_rsa_length
  end
end