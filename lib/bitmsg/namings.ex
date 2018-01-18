defmodule BitMsg.Namings do
  def gen_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64()
    |> binary_part(0, 16)
  end

  def chat_room(room_id) do
    {:global, {:chat_room, room_id}}
  end
end
