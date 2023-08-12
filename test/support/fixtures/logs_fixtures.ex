defmodule Shinstagram.LogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shinstagram.Logs` context.
  """

  @doc """
  Generate a log.
  """
  def log_fixture(attrs \\ %{}) do
    {:ok, log} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> Shinstagram.Logs.create_log()

    log
  end
end
