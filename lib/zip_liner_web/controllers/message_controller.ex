defmodule ZipLinerWeb.MessageController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Accounts
  alias ZipLiner.Social

  def index(conn, _params) do
    member = conn.assigns.current_member
    connections = Social.list_connections(member.id)

    connection_ids =
      Enum.map(connections, fn c ->
        if c.member_id_a == member.id, do: c.member_id_b, else: c.member_id_a
      end)

    connected_members =
      connection_ids
      |> Enum.map(&Accounts.get_member!/1)

    render(conn, :index, connected_members: connected_members)
  end

  def show(conn, %{"member_id" => other_member_id}) do
    current_member = conn.assigns.current_member
    other_member = Accounts.get_member!(other_member_id)

    unless Social.connected?(current_member.id, other_member.id) do
      conn
      |> put_flash(:error, "You must be connected to message this member.")
      |> redirect(to: ~p"/members/#{other_member.id}")
      |> halt()
    else
      messages = Social.list_direct_messages(current_member.id, other_member.id)
      render(conn, :show, other_member: other_member, messages: messages)
    end
  end

  def create(conn, %{"member_id" => recipient_id, "message" => %{"content" => content}}) do
    sender = conn.assigns.current_member
    recipient = Accounts.get_member!(recipient_id)

    unless Social.connected?(sender.id, recipient.id) do
      conn
      |> put_flash(:error, "You must be connected to message this member.")
      |> redirect(to: ~p"/members/#{recipient.id}")
      |> halt()
    else
      case Social.send_direct_message(%{
             sender_id: sender.id,
             recipient_id: recipient.id,
             content: content
           }) do
        {:ok, _message} ->
          if get_req_header(conn, "hx-request") != [] do
            messages = Social.list_direct_messages(sender.id, recipient.id)
            render(conn, :messages_list, messages: messages, current_member: sender)
          else
            redirect(conn, to: ~p"/messages/#{recipient_id}")
          end

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Could not send message.")
          |> redirect(to: ~p"/messages/#{recipient_id}")
      end
    end
  end
end
