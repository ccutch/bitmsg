defmodule BitMsgHttp.Server do
  use Supervisor
  alias Plug.Adapters.Cowboy

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    cowboy = Cowboy.child_spec(:http, BitMsgHttp.Router, [], port: 8000)
    children = case System.get_env("MIX_ENV") do
      "prod" -> [ cowboy ]
      # if we are not in production environment make worker to
      # build ui and watch for changes
      _ -> [
        cowboy,
        worker(BitMsgHttp.UIBuilder, [])
      ]
    end

    # IO.inspect(System.get_env("MIX_ENV"))
    # children = [cowboy]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
