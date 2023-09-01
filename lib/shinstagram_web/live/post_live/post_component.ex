defmodule ShinstagramWeb.PostLive.PostComponent do
  use ShinstagramWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="max-w-md mx-auto border-b pb-6 border-gray-300">
      <.link navigate={~p"/#{@profile.username}"} class="group block flex-shrink-0">
        <div class="flex items-center">
          <div>
            <img class="inline-block h-9 w-9 rounded-full" src={@profile.profile_photo} alt="" />
          </div>
          <div class="ml-3">
            <p class="text-base font-semibold text-gray-900 group-hover:text-gray-700">
              <%= @profile.username %>
              <span class="text-xs text-gray-500">• <%= Timex.from_now(@post.inserted_at) %></span>
            </p>
            <p class="text-xs font-medium text-gray-500"><%= @post.location %></p>
          </div>
        </div>
      </.link>
      <div class="mt-4">
        <.link navigate={~p"/posts/#{@post.id}"}>
          <img class="rounded-sm" src={@post.photo} alt={@post.photo_prompt} loading="lazy" />
        </.link>
        <%!-- Reactions --%>
        <button phx-click="like" phx-value-post-id={@post.id}>
          <.icon name="hero-heart" class="h-6 w-6 mt-3 hover:text-gray-500" />
        </button>
        <button phx-click="comment" phx-value-post-id={@post.id}>
          <.icon name="hero-chat-bubble-oval-left" class="h-6 w-6 mt-3 hover:text-gray-500" />
        </button>

        <%!-- Likes --%>
        <div class="text-xs mt-2">
          Liked by
          <%= for like <- Shinstagram.Timeline.get_likes_by_post_id(@post.id) do %>
            <.link
              class="font-bold hover:underline"
              navigate={~p"/#{Shinstagram.Profiles.get_profile!(@post.profile_id).username}"}
            >
              <%= Shinstagram.Profiles.get_profile!(like.profile_id).username %>
            </.link>
          <% end %>
        </div>

        <%!-- Caption --%>
        <p :if={not is_nil(@post.caption)} class="text-base mt-2">
          <.link class="font-bold" navigate={~p"/#{@profile.username}"}>
            <%= @profile.username %>
          </.link>
          <%= @post.caption |> String.replace("\"", "") %>
        </p>

        <%!-- Comments --%>
        <ul class="mt-2">
          <%= for comment <- @post.comments do %>
            <li class="block">
              <.link
                class="hover:underline font-bold"
                navigate={~p"/#{Shinstagram.Profiles.get_profile!(comment.profile_id).username}"}
              >
                <%= Shinstagram.Profiles.get_profile!(comment.profile_id).username %>
              </.link>
              <%= comment.body %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end
end
