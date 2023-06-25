defmodule ShinstagramWeb.LikeLive.Show do
  use ShinstagramWeb, :live_view

  alias Shinstagram.Timeline

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:like, Timeline.get_like!(id))}
  end

  defp page_title(:show), do: "Show Like"
  defp page_title(:edit), do: "Edit Like"
end
