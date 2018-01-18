defmodule BitMsg.ChatRooms.ChatRoom do
  use GenServer
  alias __MODULE__
  alias BitMsg.ChatRooms.Message

  defstruct id: nil,
            name: nil,
            messages: [],
            participants: [],
            invitations: []

  def start_link(name, id, user_id) do
    GenServer.start_link(__MODULE__, {id, name, user_id}, name: ref(id))
  end

  def init({id, name, user_id}) do
    participants = if user_id != nil, do: [user_id], else: []

    # add persistance check
    initial_state = %ChatRoom{
      id: id,
      name: name,
      participants: participants
    }

    {:ok, initial_state}
  end

  def new(id, name, user_id) do
    Supervisor.start_child(BitMsg.ChatRooms.Supervisor, [name, id, user_id])
  end

  def get_state(room_id), do: GenServer.call(ref(room_id), {:get_state})
  def get_messages(room_id), do: GenServer.call(ref(room_id), {:get_messages})

  def send_message(room_id, %Message{} = message),
    do: GenServer.cast(ref(room_id), {:send_message, message})

  def get_messages_for_user(room_id, user_id),
    do: GenServer.call(ref(room_id), {:get_messages_for, user_id})

  def create_invitation(room_id, multiuse \\ false),
    do: GenServer.call(ref(room_id), {:create_invitation, multiuse})

  def redeem_invitation(room_id, invitation, user),
    do: GenServer.call(ref(room_id), {:redeem_invitation, invitation, user})

  # Callback functions
  def handle_cast({:send_message, message}, state) do
    new_state = %ChatRoom{state | messages: state.messages ++ [message]}
    {:noreply, new_state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_messages}, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_call({:get_messages_for, user_id}, _from, state) do
    messages =
      state.messages
      |> Enum.filter(fn message ->
        message.recipient == user_id or message.sender == user_id
      end)

    {:reply, messages, state}
  end

  def handle_call({:create_invitation, multiuse}, _from, state) do
    id = BitMsg.Namings.gen_id()

    id =
      if multiuse do
        "m-" <> id
      else
        id
      end

    new_state = %ChatRoom{state | invitations: state.invitations ++ [id]}

    {:reply, id, new_state}
  end

  def handle_call({:redeem_invitation, invitation, user}, _from, state) do
    case invitation in state.invitations do
      false ->
        {:error, :invitation_does_not_exist}

      true ->
        invitations =
          case invitation do
            "m-" <> _id -> state.invitations
            _ -> List.delete(state.invitations, invitation)
          end

        new_state = %ChatRoom{
          state
          | invitations: invitations,
            participants: state.participants ++ [user]
        }

        {:reply, new_state, new_state}
    end
  end

  defdelegate ref(room_id), to: BitMsg.Namings, as: :chat_room
end
