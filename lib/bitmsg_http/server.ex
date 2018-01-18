defmodule BitMsgHttp.Server do
  use Supervisor
  alias Plug.Adapters.Cowboy

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Cowboy.child_spec(:http, BitMsgHttp.Router, [], port: 8000),
      worker(BitMsgHttp.UIBuilder, [])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
