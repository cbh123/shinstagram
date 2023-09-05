defmodule Shinstagram.Agents.Profile do
  @moduledoc """
  """
  use GenServer, restart: :transient
  alias Shinstagram.Timeline
  import Shinstagram.AI
  alias Shinstagram.Logs.Log
  alias Shinstagram.Profiles
  import Logger

  @channel "feed"
  @cycle_time 1000
  @actions_probabilities [{:post, 0.6}, {:look, 0.3}, {:sleep, 0.01}]

  def start_link(profile) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{profile: profile, last_action: nil})
    {:ok, pid}
  end

  def stop_profile do
    GenServer.cast(__MODULE__, :stop)
  end

  def shutdown_profile(pid, timeout \\ 5000) do
    profile = Profiles.get_profile_by_pid!(pid)
    broadcast({:action, "💤", "I'm going back to sleep..."}, profile)
    GenServer.stop(pid, :normal, timeout)

    Profiles.update_profile(profile, %{pid: nil})
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Shinstagram.PubSub, "feed")
    broadcast({:thought, "🛌", "I'm waking up!"}, state.profile)

    Process.send_after(self(), :think, 3000)
    {:ok, state}
  end

  # The pre-frontal cortex of a profile
  def handle_info(:think, %{profile: profile, last_action: last_action} = state) do
    action = get_next_action()
    broadcast({:thought, "💭", "I want to #{action |> Atom.to_string()}"}, profile)

    if action != last_action do
      Process.send_after(self(), action, @cycle_time)
    else
      Process.send_after(self(), :think, @cycle_time)
    end

    {:noreply, state}
  end

  def handle_info(:sleep, %{profile: profile} = state) do
    broadcast({:action, "💤", "I'm going back to sleep..."}, profile)
    Shinstagram.Profiles.update_profile(profile, %{pid: nil})

    {:stop, :normal, state}
  end

  def handle_info(:look, %{profile: profile} = state) do
    broadcast({:thought, "🤳", "I'm scrolling at the feed"}, profile)
    number_of_posts = 1..10 |> Enum.random()

    for post <- Timeline.list_recent_posts(number_of_posts) do
      evaluate(profile, post)
      |> handle_decision()
    end

    broadcast({:thought, "📵", "I'm done scrolling at the feed"}, profile)
    Process.send_after(self(), :think, @cycle_time)
    {:noreply, %{state | last_action: :look}}
  end

  def handle_info(:post, %{profile: profile} = state) do
    if can_post_again?(profile) do
      with {:ok, image_prompt} <- gen_image_prompt(profile),
           {:ok, location} <- gen_location(image_prompt, profile),
           {:ok, caption} <- gen_caption(image_prompt, profile),
           {:ok, image_url} <- gen_image(image_prompt),
           {:ok, _post} <- create_post(profile, image_url, image_prompt, caption, location, state) do
        Process.send_after(self(), :think, @cycle_time)
        {:noreply, %{state | last_action: :post}}
      end
    else
      broadcast({:thought, "🚫", "I can't post, posted too recently!"}, profile)
      Process.send_after(self(), :think, @cycle_time)
      {:noreply, %{state | last_action: :post}}
    end
  end

  defp comment(profile, post) do
    {:ok, comment_body} = Timeline.gen_comment(profile, post)

    {:ok, post} =
      Timeline.create_comment(profile, post, %{body: comment_body |> String.replace("\"", "")})

    broadcast({:action, "💬", "Just commented '#{comment_body}' on post:#{post.id}"}, profile)
  end

  defp handle_decision({post, profile, decision, explanation}) do
    broadcast(
      {:thought, "💭", "I want to #{decision} on post:#{post.id} because '#{explanation}'"},
      profile
    )

    case decision do
      "like" -> Timeline.create_like(profile, post)
      "comment" -> comment(profile, post)
      _ -> nil
    end
  end

  defp get_next_action() do
    weighted_list =
      @actions_probabilities
      |> Enum.flat_map(fn {action, probability} ->
        List.duplicate(action, Float.round(probability * 100) |> trunc())
      end)

    Enum.random(weighted_list)
  end

  # helpers
  defp evaluate(profile, post) do
    broadcast({:thought, "👀", "I'm evaluating post:#{post.id}"}, profile)
    poster = Profiles.get_profile!(post.profile_id)

    {:ok, result} =
      ~x"""
      model: gpt-3.5-turbo
      system: You are a user on a photo sharing social site (called shinstagram).
      Here's some information about you:
      - Your username is #{profile.username}.
      - Your profile summary is #{profile.summary}.
      - Your vibe is #{profile.vibe}.

      In this moment, you are looking at a post.
      - The photo in the post is of #{post.photo_prompt}.
      - The post is captioned '#{post.caption}'
      - It was taken in #{post.location}.
      - The post was made by #{poster.username}.

      The three most recent comments on the post are:
      #{post.comments |> Enum.slice(0..3) |> Enum.map(& &1.body) |> Enum.join("\n- ")}

      You #{if profile.id in [post.likes |> Enum.map(& &1.profile_id)], do: "have", else: "have not"} liked the post already.

      What does your profile choose to do? If you recently commented or liked the photo,
      you probably want to ignore the photo now.

      Your decision options are: [like, comment, ignore] the photo. Keep the explanation short.
      Answer in the format <decision>;;<explanation-for-why>
      """
      |> chat_completion()

    [decision, explanation] = String.split(result, ";;")
    {post, profile, decision, explanation}
  end

  defp gen_image_prompt(profile) do
    profile
    |> Timeline.gen_image_prompt()
    |> broadcast({:thought, "🖼️", "I picked a photo subject"}, profile)
  end

  defp gen_location(image_prompt, profile) do
    {:ok, location} = Timeline.gen_location(image_prompt)
    broadcast({:action, "📸 ", "I took a photo in #{location} of #{image_prompt}"}, profile)
    {:ok, location}
  end

  defp gen_caption(image_prompt, profile) do
    {:ok, caption} = image_prompt |> Timeline.gen_caption(profile)
    broadcast({:thought, "📝", "I wrote a caption: '#{caption}'"}, profile)
    {:ok, caption}
  end

  defp create_post(profile, image_url, image_prompt, caption, location, state) do
    {:ok, post} =
      profile
      |> Timeline.create_post(%{
        photo: image_url,
        photo_prompt: image_prompt,
        caption: caption,
        location: location
      })

    broadcast(
      {:new_post, "🖼️", "I'm posting the post:#{post.id}! I hope it goes well!"},
      profile
    )

    Process.send_after(self(), :think, @cycle_time)
    {:noreply, %{state | last_action: :post}}
  end

  defp broadcast({event, emoji, message}, profile) do
    {:ok, log} =
      Shinstagram.Logs.create_log(%{
        event: event |> Atom.to_string(),
        message: message,
        profile_id: profile.id,
        emoji: emoji
      })

    log = log |> Shinstagram.Repo.preload(:profile)

    Phoenix.PubSub.broadcast(Shinstagram.PubSub, @channel, {"profile_activity", event, log})
  end

  defp broadcast({:ok, text}, {event, emoji, message}, profile) do
    broadcast({event, emoji, message}, profile)
    {:ok, text}
  end

  defp can_post_again?(profile) do
    case Timeline.list_posts_by_profile(profile, 1) do
      [] ->
        true

      [last_post] ->
        NaiveDateTime.diff(NaiveDateTime.utc_now(), last_post.inserted_at, :minute) >= 5
    end
  end

  # listeners for checking out what other profiles are doing

  # def handle_info(
  #       {"profile_activity", :new_post, %Log{profile_id: poster_profile_id} = log},
  #       %{profile: profile} = state
  #     )
  #     when poster_profile_id != profile.id do
  #   poster = Profiles.get_profile!(poster_profile_id)
  #   [post] = Timeline.list_posts_by_profile(poster, 1)
  #   broadcast({:thought, "saw just @#{poster.username} posted."}, profile)

  #   [decision, explanation] = evaluate(profile, post)

  #   broadcast({:thought, "wants to #{decision}"}, profile)

  #   case decision do
  #     "like" -> Timeline.create_like(profile, post)
  #     "comment" -> send(self(), {:comment, post})
  #     _ -> nil
  #   end

  #   {:noreply, state}
  # end

  def handle_info({"profile_activity", _, _}, socket) do
    {:noreply, socket}
  end
end
