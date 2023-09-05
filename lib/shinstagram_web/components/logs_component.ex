defmodule ShinstagramWeb.LogsComponent do
  use ShinstagramWeb, :live_component

  def render_post_link(text) do
    regex = ~r/post:(?<id>[a-f0-9\-]+)/

    replaced =
      Regex.replace(regex, text, fn _, id ->
        "<a class=\"font-bold hover:underline\" href=\"/posts/#{id}\">post</a>"
      end)

    Phoenix.HTML.raw(replaced)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-96 overflow-y-scroll">
      <div class="">
        <div class="mt-8 flow-root">
          <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
            <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
              <table class="min-w-full divide-y divide-gray-300">
                <thead>
                  <tr>
                    <th
                      scope="col"
                      class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0"
                    >
                      Profile
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Emoji
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Monologue
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Process
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Time
                    </th>
                  </tr>
                </thead>
                <tbody id={@id} phx-update="stream" class="divide-y divide-gray-200 bg-white">
                  <tr :for={{id, log} <- @logs} id={id}>
                    <td class="whitespace-nowrap py-5 pl-4 pr-3 text-sm sm:pl-0">
                      <.link class="flex items-center" navigate={"/#{log.profile.username}"}>
                        <div class="h-11 w-11 flex-shrink-0">
                          <img class="h-11 w-11 rounded-full" src={log.profile.profile_photo} alt="" />
                        </div>
                        <div class="ml-4">
                          <div class="font-medium text-gray-900">
                            <%= log.profile.name %>
                          </div>
                          <div class="mt-1 text-gray-500">@<%= log.profile.username %></div>
                        </div>
                      </.link>
                    </td>
                    <td class="px-3 py-5 text-xl text-gray-500">
                      <div class="text-gray-900"><%= log.emoji %></div>
                    </td>
                    <td class="px-3 py-5 text-xs text-gray-400 italic">
                      <div class="text-gray-900"><%= render_post_link(log.message) %></div>
                    </td>
                    <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                      <%= if log.profile.pid do %>
                        <%= log.profile.pid %>
                      <% else %>
                        <span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">
                          Asleep
                        </span>
                      <% end %>
                    </td>
                    <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                      <%= Timex.from_now(log.inserted_at) %>
                    </td>
                  </tr>
                  <!-- More people... -->
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
