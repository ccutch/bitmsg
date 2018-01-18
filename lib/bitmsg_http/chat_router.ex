defmodule BitMsgHttp.ChatRouter do
  use Plug.Router
  use Plug.ErrorHandler

  import BitMsgHttp.Utils
  alias BitMsg.ChatRooms.{ChatRoom, Message}

  plug Plug.Parsers, parsers: [:json],
                     pass:  ["application/json"],
                     json_decoder: Poison
  plug :authenticate_user, required: false
  plug :match
  plug :dispatch


  # post "/" do
  get "/create" do
    %{"name" => name} = conn.body_params
    user = conn.private[:user]

    room_id = BitMsg.ChatRooms.create_room(name, user.id)
    send_json(conn, room_id)
  end

  get "/:room_id" do
      state = ChatRoom.get_state(room_id)
      send_json(conn, state)
  end

  get "/:room_id/messages" do
    messages = ChatRoom.get_messages_for_user(room_id, "test-user")
    send_resp(conn, 200, Poison.encode!(messages))
  end

  # post "/:room_id/messages" do
  get "/:room_id/create_message" do
    message = %Message{
      signature: "fake-sig",
      body: "sad-fsdfsdf-sdFSDF_DFsDFsdf-ASdfsD_FsdfS_Df",
      sender: "fake-sender",
      recipient: "test-user"
    }
    message = ChatRoom.send_message(room_id, message)
    # add pubsub with client
    send_resp(conn, 200, Poison.encode!(message))
  end

  get "/:room_id/create_invitation" do
    invitation = ChatRoom.create_invitation(room_id)

    send_resp(conn, 200, Poison.encode!(invitation))
  end

  get "/:room_id/redeem/:invitation" do
    invitation = ChatRoom.redeem_invitation(room_id, invitation, "new-user")

    send_resp(conn, 200, Poison.encode!(invitation))
  end

  match _ do
    conn
    |> put_resp_content_type("plain/text")
    |> send_resp(404, "Route not found")
  end

  def handle_errors(conn, %{reason: reason} = error) do
    IO.inspect(error)
    {reason, _} = reason
    status = case reason do
      # no genserver with name
      :noproc -> 404
      _ -> 500
    end

    send_resp(conn, status, "not found")
  end
end