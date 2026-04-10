defmodule ZipLinerWeb.CoreComponents do
  @moduledoc """
  Core UI components used throughout ZipLiner.
  """

  use Phoenix.Component
  use ZipLinerWeb, :verified_routes

  import ZipLinerWeb.Gettext

  @doc """
  Renders a flash message group.
  """
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <%= if msg = Phoenix.Flash.get(@flash, :info) do %>
      <div class="flash flash-info" role="alert">
        <p><%= msg %></p>
      </div>
    <% end %>
    <%= if msg = Phoenix.Flash.get(@flash, :error) do %>
      <div class="flash flash-error" role="alert">
        <p><%= msg %></p>
      </div>
    <% end %>
    """
  end

  @doc """
  Renders a member avatar.
  """
  attr :member, :map, required: true
  attr :size, :string, default: "sm"

  def member_avatar(assigns) do
    ~H"""
    <img
      src={@member.github_avatar_url}
      alt={@member.display_name}
      class={"avatar-#{@size}"}
    />
    """
  end

  @doc """
  Renders a cohort badge.
  """
  attr :cohort, :map, required: true

  def cohort_badge(assigns) do
    ~H"""
    <span class="cohort-badge"><%= @cohort.name %></span>
    """
  end
end
