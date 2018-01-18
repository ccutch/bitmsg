defmodule BitMsg.ChatRooms do
  alias BitMsg.Namings
  alias BitMsg.ChatRooms.ChatRoom
  alias BitMsg.ChatRooms.Supervisor, as: ChatRoomSupervisor

  def create_room(name \\ "Test Room", user_id \\ nil) do
    id = Namings.gen_id()

    {:ok, pid} = ChatRoom.new(id, name, user_id)
    ChatRoomSupervisor.id_for_pid(pid)
  end
end