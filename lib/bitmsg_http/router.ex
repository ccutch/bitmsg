defmodule BitMsgHttp.Router do
  use Plug.Router

  plug Plug.Static, at: "/dist", from: "dist/"
  plug :match
  plug :dispatch

  # get "/" do
  #   send_resp(conn, 200, "You did it!")
  # end

  forward "/api/room", to: BitMsgHttp.ChatRouter
  forward "/api/user", to: BitMsgHttp.UserRouter
  # forward "/api/user", to: BitMsgHttp.UserRouter

  match _ do
    send_file(conn, 200, "dist/index.html")
  end
end