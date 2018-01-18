defmodule BitMsg.Users do
  alias BitMsg.Namings

  def create(pub_key) do
    id = Namings.gen_id()
    {:ok, pid} = Supervisor.start_child(BitMsg.Users.Supervisor, [id, pub_key])

    case :sys.get_state(pid) do
      {:error, _any_error} -> nil
      state -> state
    end
  end

  def get_user(user_id) do
    GenServer.call({:global, user_id}, :get_state)
  end

  def update_user(user_id, updates) do
    GenServer.call({:global, user_id}, {:update, updates})
  end
end