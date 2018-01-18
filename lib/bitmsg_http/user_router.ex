defmodule BitMsgHttp.UserRouter do
  use Plug.Router
  use Plug.ErrorHandler

  import BitMsgHttp.Utils

  plug Plug.Parsers, parsers: [:json],
                     pass:  ["application/json"],
                     json_decoder: Poison
  plug :authenticate_user
  plug :match
  plug :dispatch


  post "/" do
  # get "/create" do
    %{"pub_key" => pub_key} = conn.body_params
    # pub_key = "fake-key"

    user = BitMsg.Users.create(pub_key)
    send_json(conn, user)
  end

  get "/:user_id" do
    user = BitMsg.Users.get_user(user_id)
    send_json(conn, user)
  end

  patch "/:user_id" do
    user = BitMsg.Users.update_user(user_id, conn.body_params)
    send_json(conn, user)
  end

  match _ do
    conn
    |> put_resp_content_type("plain/text")
    |> send_resp(404, "Route not found")
  end
end