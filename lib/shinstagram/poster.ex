defmodule Shinstagram.Poster do
  @server Shinstagram.Poster.Server

  def start_link(profile) do
    GenServer.start_link(@server, profile, name: @server, debug: [:trace])
  end

  def new_post() do
    GenServer.cast(@server, :new_post)
  end
end
