defmodule BitMsg.Users.Supervisor do
  use Supervisor
  alias BitMsg.Users.User

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(User, [])
    ]
    
    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end