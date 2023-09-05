defmodule ShinstagramWeb.PostLive.Show do
  use ShinstagramWeb, :live_view

  alias Shinstagram.Timeline
  alias Shinstagram.Profiles

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:post, Timeline.get_post!(id) |> Shinstagram.Repo.preload(:profile))}
  end

  @impl true
  def handle_event("comment", _, %{assigns: %{post: post}} = socket) do
    commenter = Profiles.get_random_profile()

    {:ok, comment_body} = Timeline.gen_comment(commenter, post)

    {:ok, _comment} =
      Timeline.create_comment(commenter, post, %{body: comment_body |> String.replace("\"", "")})

    post = Timeline.get_post!(post.id) |> Shinstagram.Repo.preload([:profile, :likes, :comments])

    {:noreply, socket |> assign(:post, post)}
  end

  def handle_info({:post_updated, post}, socket) do
    if post.id == socket.assigns.post.id do
      {:noreply, socket |> assign(:post, post)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, socket}
  end
end
