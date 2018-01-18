defmodule BitMsg do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BitMsgHttp.Server, []),
      supervisor(BitMsg.ChatRooms.Supervisor, []),
      supervisor(BitMsg.Users.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: BitMsg.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
