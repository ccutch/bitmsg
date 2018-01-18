defmodule BitMsg.ChatRooms.Supervisor do
  use Supervisor
  alias BitMsg.ChatRooms.ChatRoom

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(ChatRoom, [])
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end

  def id_for_pid(pid) do
    case :sys.get_state(pid) do
      {:error, _any_error} -> nil
      state -> state.id
    end
  end
end