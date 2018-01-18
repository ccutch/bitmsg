defmodule BitMsg.Users.User do
  use GenServer

  alias __MODULE__

  defstruct id: "",
            name: "Anon",
            avatar: "http://s3.amazonaws.com/37assets/svn/765-default-avatar.png",
            pub_key: ""
  
  def start_link(id, pub_key) do
    GenServer.start_link(__MODULE__, [id, pub_key], name: {:global, id})
  end

  def init([id, pub_key]) do
    {:ok, %User{id: id, pub_key: pub_key}}
  end

  def handle_call({:update, %{} = updates}, _from, state) do
    new_state = %User{
      state |
      name: Map.get(updates, "name", state.name),
      avatar: Map.get(updates, "avatar", state.avatar)
    }

    {:reply, new_state, new_state}
  end

  def handle_call(:get_key, _from, state) do
    {:reply, state.pub_key, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end