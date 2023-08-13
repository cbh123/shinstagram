defmodule Shinstagram.Poster.Server do
  use GenServer
  alias Shinstagram.Poster.Impl
  alias Shinstagram.Timeline

  def init(initial_number) do
    {:ok, initial_number}
  end

  def handle_cast(:new_post, profile) do
    send(self(), :gen_image_prompt)
    {:noreply, profile}
  end

  def handle_info(:gen_image_prompt, profile) do
    {:ok, image_prompt} = Timeline.gen_image_prompt(profile)
    send(self(), :gen_caption)
    {:noreply, %{profile: profile, image_prompt: image_prompt}}
  end

  def handle_info(:gen_caption, %{profile: profile, image_prompt: image_prompt}) do
    {:ok, caption} = Timeline.gen_caption(profile, image_prompt)
    {:noreply, %{profile: profile, image_prompt: image_prompt, caption: caption}}
  end

  def format_status(_reason, [_pdict, state]) do
    [data: [{'State', "My current state is #{inspect(state)}"}]]
  end

  def terminate(reason, state) do
    IO.puts("Terminating with reason #{inspect(reason)} and state #{inspect(state)}")
  end
end
