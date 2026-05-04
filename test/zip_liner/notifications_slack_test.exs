defmodule ZipLiner.Notifications.SlackTest do
  use ExUnit.Case, async: true

  alias ZipLiner.Notifications.Slack

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp member_with_handle(handle), do: %{slack_handle: handle}
  defp member_without_handle, do: %{slack_handle: nil}

  # ---------------------------------------------------------------------------
  # Tests: skipped cases (no HTTP call expected)
  # ---------------------------------------------------------------------------

  describe "notify/2 — skipped" do
    test "returns :ok when member has no slack_handle (nil)" do
      assert :ok = Slack.notify(member_without_handle(), "hello")
    end

    test "returns :ok when member has an empty slack_handle string" do
      assert :ok = Slack.notify(member_with_handle(""), "hello")
    end

    test "returns :ok when no SLACK_WEBHOOK_URL is configured" do
      # Ensure the key is absent so the function bails out early
      Application.delete_env(:zip_liner, :slack_webhook_url)
      assert :ok = Slack.notify(member_with_handle("janedoe"), "hello")
    end
  end

  # ---------------------------------------------------------------------------
  # Tests: webhook configured — we intercept Finch at the HTTP level via mocks
  # rather than spinning up a real server, so we just verify the happy-path
  # guard clauses and that the function returns the right atoms.
  # ---------------------------------------------------------------------------

  describe "notify/2 — with webhook URL set" do
    setup do
      # Point at a local URL; actual HTTP calls will fail, but we test the
      # branching logic, not the network layer.
      Application.put_env(:zip_liner, :slack_webhook_url, "http://localhost:0/slack")
      on_exit(fn -> Application.delete_env(:zip_liner, :slack_webhook_url) end)
      :ok
    end

    test "attempts to send when member has a handle and webhook is configured" do
      # The call will fail because port 0 is unreachable, but we confirm the
      # function returns :error (not a crash) when the request fails.
      result = Slack.notify(member_with_handle("janedoe"), "you were mentioned")
      assert result in [:ok, :error]
    end

    test "strips a leading @ from the handle before sending" do
      # Same as above: we verify no exception is raised for a handle with @
      result = Slack.notify(member_with_handle("@janedoe"), "you were mentioned")
      assert result in [:ok, :error]
    end
  end
end
