defmodule ZipLiner.Notifications.Slack do
  @moduledoc """
  Sends notifications to Slack via an Incoming Webhook URL.

  When a ZipLiner member with a configured `slack_handle` is mentioned or
  receives a direct message, this module posts a brief alert to the
  configured Slack workspace so the recipient sees it in Slack.

  ## Setup

  1. Create a Slack app with an Incoming Webhook at
     https://api.slack.com/apps and install it to your workspace.
  2. Set the `SLACK_WEBHOOK_URL` environment variable to the webhook URL
     provided by Slack (e.g. `https://hooks.slack.com/services/T.../B.../...`).
  3. Users set their Slack handle (without the leading `@`) in their
     ZipLiner profile. Notifications are silently skipped for members who
     have not set a handle or when no webhook URL is configured.
  """

  require Logger

  @doc """
  Sends a Slack notification to `member` if they have a `slack_handle` set.

  The `message` string is appended after the Slack mention, for example:

      "you were mentioned in a forum thread: \"Intro to Elixir\""

  Returns `:ok` on success or when skipped (no handle / no webhook URL).
  Returns `:error` when the HTTP request fails or Slack returns an error.
  """
  def notify(%{slack_handle: handle}, message)
      when is_binary(handle) and handle != "" do
    case webhook_url() do
      nil ->
        :ok

      url ->
        # Strip a leading @ the user may have included when saving their handle
        bare_handle = String.trim_leading(handle, "@")
        text = "<@#{bare_handle}> #{message}"
        post(url, text)
    end
  end

  def notify(_member, _message), do: :ok

  @doc """
  Returns `true` when a Slack webhook URL is configured, `false` otherwise.
  Useful for displaying webhook status in the UI.
  """
  def configured? do
    webhook_url() != nil
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp webhook_url do
    Application.get_env(:zip_liner, :slack_webhook_url)
  end

  defp post(url, text) do
    body = Jason.encode!(%{text: text})
    headers = [{"content-type", "application/json"}]
    request = Finch.build(:post, url, headers, body)

    case Finch.request(request, ZipLiner.Finch) do
      {:ok, %Finch.Response{status: 200}} ->
        :ok

      {:ok, %Finch.Response{status: status, body: resp_body}} ->
        Logger.warning("Slack webhook returned HTTP #{status}: #{resp_body}")
        :error

      {:error, reason} ->
        Logger.warning("Slack webhook request failed: #{inspect(reason)}")
        :error
    end
  end
end
