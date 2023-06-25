defmodule ShinstagramWeb.LikeLive.Index do
  use ShinstagramWeb, :live_view

  alias Shinstagram.Timeline
  alias Shinstagram.Timeline.Like

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :likes, Timeline.list_likes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Like")
    |> assign(:like, Timeline.get_like!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Like")
    |> assign(:like, %Like{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Timeline")
    |> assign(:like, nil)
  end

  @impl true
  def handle_info({ShinstagramWeb.LikeLive.FormComponent, {:saved, like}}, socket) do
    {:noreply, stream_insert(socket, :likes, like)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    like = Timeline.get_like!(id)
    {:ok, _} = Timeline.delete_like(like)

    {:noreply, stream_delete(socket, :likes, like)}
  end
end
