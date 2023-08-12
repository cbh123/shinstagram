defmodule ShinstagramWeb.PostLive.Index do
  use ShinstagramWeb, :live_view

  alias Shinstagram.Timeline
  alias Shinstagram.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    {:ok, stream(socket, :posts, Timeline.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Timeline")
    |> assign(:post, nil)
  end

  def handle_event("gen-profile", _, socket) do
    {:ok, profile} = Timeline.gen_profile()

    {:noreply,
     socket |> redirect(to: ~p"/#{profile.username}") |> put_flash(:info, "New profile created")}
  end

  def handle_info({:like, username, post_id}, socket) do
    profile = Shinstagram.Profiles.get_profile_by_username!(username)
    post = Shinstagram.Timeline.get_post!(post_id)
    Shinstagram.Timeline.create_like(profile, post)

    {:noreply, socket |> stream_insert(:posts, post)}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post, at: 0)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post)}
  end

  @impl true
  def handle_info({ShinstagramWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  def handle_event("like", %{"post_id" => id}, socket) do
    # send(self(), {:like, "elon", id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
