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

  def start_link(profile) do
    GenServer.start_link(__MODULE__, %{profile: profile, last_action: nil})
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Shinstagram.PubSub, "feed")

    Process.send_after(self(), :think, 0)
    {:ok, state}
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

  # The pre-frontal cortext of a profile
  def handle_info(:think, %{profile: profile, last_action: last_action} = state) do
    actions = [:post, :look]

    action = Enum.random(actions)
    broadcast({:thought, "wants to #{action |> Atom.to_string()}"}, profile)

    if action != last_action do
      Process.send_after(self(), action, 1000)
    else
      Process.send_after(self(), :think, 1000)
    end

    {:noreply, state}
  end

  def handle_info(:look, %{profile: profile} = state) do
    broadcast({:thought, "is scrolling at the feed"}, profile)
    number_of_posts = 1..10 |> Enum.random()

    for post <- Timeline.list_recent_posts(number_of_posts) do
      evaluate(profile, post)
      |> handle_decision()
    end

    broadcast({:thought, "is DONE scrolling at the feed"}, profile)
    Process.send_after(self(), :think, 1000)
    {:noreply, %{state | last_action: :look}}
  end

  def handle_info(:post, %{profile: profile} = state) do
    if can_post_again?(profile) do
      with {:ok, image_prompt} <- gen_image_prompt(profile),
           {:ok, location} <- gen_location(image_prompt, profile),
           {:ok, caption} <- gen_caption(image_prompt, profile),
           {:ok, image_url} <- gen_image(image_prompt),
           {:ok, post} <- create_post(profile, image_url, image_prompt, caption, location) do
        Process.send_after(self(), :think, 1000)
        {:noreply, %{state | last_action: :post}}
      end
    else
      broadcast({:thought, "can't post, posted too recently!"}, profile)
      Process.send_after(self(), :think, 1000)
      {:noreply, %{state | last_action: :post}}
    end
  end

  defp comment(profile, post) do
    {:ok, comment_body} = Timeline.gen_comment(profile, post)

    {:ok, post} =
      Timeline.create_comment(profile, post, %{body: comment_body |> String.replace("\"", "")})

    broadcast({:action, "just commented '#{comment_body}' on #{post.id}"}, profile)
  end

  defp handle_decision({post, profile, decision, explanation}) do
    broadcast({:thought, "wants to #{decision} because #{explanation}"}, profile)

    case decision do
      "like" -> Timeline.create_like(profile, post)
      "comment" -> comment(profile, post)
      _ -> nil
    end
  end

  # helpers
  defp evaluate(profile, post) do
    broadcast({:thought, "is evaluating post:#{post.id}"}, profile)
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

      Your decision options are: [like, comment, ignore] the photo.
      Answer in the format <decision>;;<explanation>
      """
      |> chat_completion()

    [decision, explanation] = String.split(result, ";;")
    {post, profile, decision, explanation}
  end

  defp gen_image_prompt(profile) do
    profile
    |> Timeline.gen_image_prompt()
    |> broadcast({:thought, "picked a photo subject"}, profile)
  end

  defp gen_location(image_prompt, profile) do
    {:ok, location} = Timeline.gen_location(image_prompt)
    broadcast({:action, "just took a photo in #{location} of #{image_prompt}"}, profile)
    {:ok, location}
  end

  defp gen_caption(image_prompt, profile) do
    {:ok, caption} = image_prompt |> Timeline.gen_caption(profile)
    broadcast({:thought, "wrote a caption: '#{caption}'"}, profile)
    {:ok, caption}
  end

  defp create_post(profile, image_url, image_prompt, caption, location) do
    profile
    |> Timeline.create_post(%{
      photo: image_url,
      photo_prompt: image_prompt,
      caption: caption,
      location: location
    })
    |> broadcast({:new_post, "posting photo! hope it goes well!"}, profile)
  end

  defp broadcast({event, message}, profile) do
    {:ok, log} =
      Shinstagram.Logs.create_log(%{
        event: event |> Atom.to_string(),
        message: "#{profile.username} #{message}",
        profile_id: profile.id
      })

    Phoenix.PubSub.broadcast(Shinstagram.PubSub, @channel, {"profile_activity", event, log})
  end

  defp broadcast({:ok, text}, {event, message}, profile) do
    broadcast({event, message}, profile)
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
end
