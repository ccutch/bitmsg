defmodule BitMsgHttp.Utils do
  import Plug.Conn

  @auth_header "authorization"

  def authenticate_user(conn, opts) do
    required = opts[:required] || false

    check_header = fn {key, _} -> key == @auth_header end

    case Enum.find(conn.req_headers, check_header) do
      # NO token give 401 (Unauthorized) response
      nil ->
        if required do
          conn
          |> send_resp(401, "No token given")
          |> halt()
        else
          conn
        end

      {@auth_header, token} ->
        conn
        |> put_private(:user, %{
          id: "test-user=======",
          token: token,
          name: "Connor McCutcheon",
          devices: [
            %{name: "Sbux Laptop", public_key: "--...--"}
          ]
        })
    end
  end

  def send_json(conn, object, code \\ 200) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(object))
  end
end
