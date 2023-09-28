defmodule Shinstagram.Timeline do
  @moduledoc """
  Everything to do with timelines.any()
  """

  import Ecto.Query, warn: false
  import AI
  import Shinstagram.AI
  alias Shinstagram.Repo

  alias Shinstagram.Profiles.Profile
  alias Shinstagram.Timeline.{Post, Like}
  require Logger

  @model "gpt-4"
  @dumb_model "gpt-3.5-turbo"

  def log(message) do
    Logger.info(message)
    {:ok, log} = Shinstagram.Logs.create_log(%{event: "profiles", status: message})

    Phoenix.PubSub.broadcast(Shinstagram.PubSub, "profiles", {"profiles", log})
  end

  @doc """
  Given a profile and a post, generate a comment.
  """
  def gen_comment(%Profile{username: username, summary: summary, vibe: vibe}, %Post{} = post) do
    Logger.info("Generating comment for #{username} on post #{post.id}")

    ~l"""
    model: #{@model}
    system: You are a user on a photo sharing social network site (like instagram).
    Here's some information about you:
    - Your username is #{username}.
    - Your profile summary is #{summary}.
    - Your vibe is #{vibe}.

    In this moment, you are commenting on a post.
    - The photo in the post is of #{post.photo_prompt}.
    - The post is captioned '#{post.caption}'
    - It was taken in #{post.location}.
    - The post was made by #{post.profile.username}.

    You are commenting on the post. Comments are generally pretty short (maybe one sentence, or a few words, no hashtags).

    Your comment is:
    """
    |> chat_completion()
  end

  @doc """
  Gathers all the relevant info from a profile and generates a text-to-image prompt,
  as well as a caption for the photo.

  Returns {:ok, image_prompt}.

  ## Examples

      iex> create_image_prompt(profile)
      "A futuristic digital artwork with clean lines, neon glows, and dark background featuring bright, colorful accents."
  """
  def gen_image_prompt(%Profile{username: username, summary: summary, vibe: vibe}) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts. The following profile is posting a photo to a social network and we need a way of describing the image they're posting. Can you output the text-to-image prompt? It should match the vibe of the profile. Don't include the word 'caption' in your output.
    user: Username: #{username} Summary: #{summary} Vibe: #{vibe}
    """
    |> chat_completion()
  end

  @doc """
  Generates the caption for the image.

  Returns {:ok, caption}
  """
  def gen_caption(
        image_prompt,
        %Profile{username: username, summary: summary, vibe: vibe}
      ) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating captions for social media posts. The following profile is posting a photo to a social network and we need a caption for the photo. Can you output the caption? It should match the vibe of the profile. Don't include the word 'caption' in your output.
    user: Username: #{username} Summary: #{summary} Vibe: #{vibe}. Photo description: #{image_prompt}
    """
    |> chat_completion()
  end

  def gen_location(image_prompt) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating locations for social media posts. The following profile is posting a photo to a social network and we need a location for the photo. Can you output the location? It should match the vibe of the profile. Don't include the word 'location' in your output.
    user: #{image_prompt}
    """
    |> chat_completion()
  end

  alias Shinstagram.Agents

  @doc """
  Given a profile, generate a post.
  """
  def gen_post(profile) do
    with {:ok, image_prompt} <- gen_image_prompt(profile),
         {:ok, caption} <- gen_caption(image_prompt, profile),
         {:ok, location} <- gen_location(image_prompt),
         {:ok, image_url} <- gen_image(image_prompt) do
      create_post(profile, %{
        photo: image_url,
        photo_prompt: image_prompt,
        caption: caption,
        location: location
      })
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """

  def list_posts do
    from(p in Post, order_by: [desc: p.inserted_at])
    |> Repo.all()
    |> Repo.preload(:profile)
    |> Repo.preload(:comments)
  end

  def list_posts_by_profile(profile) do
    Repo.all(from(p in Post, where: p.profile_id == ^profile.id, order_by: [desc: p.inserted_at]))
  end

  def list_posts_by_profile(profile, limit) do
    Repo.all(
      from(p in Post,
        where: p.profile_id == ^profile.id,
        order_by: [desc: p.inserted_at],
        limit: ^limit
      )
    )
    |> Repo.preload([:comments, :profile, :likes])
  end

  def list_recent_posts(limit) do
    from(p in Post, order_by: [desc: p.inserted_at], limit: ^limit)
    |> Repo.all()
    |> Repo.preload([:profile, :likes, :comments])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload([:profile, :likes, :comments])

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Profile{} = profile, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:profile, profile)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Shinstagram.PubSub, "posts")
  end

  defp broadcast({:error, _reason} = error, _), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(
      Shinstagram.PubSub,
      "posts",
      {event, post |> Repo.preload(:comments)}
    )

    {:ok, post}
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def get_likes_by_post_id(post_id) do
    Repo.all(from(l in Like, where: l.post_id == ^post_id))
  end

  @doc """
  Returns the list of likes.

  ## Examples

      iex> list_likes()
      [%Like{}, ...]

  """
  def list_likes do
    Repo.all(Like)
  end

  @doc """
  Gets a single like.

  Raises `Ecto.NoResultsError` if the Like does not exist.

  ## Examples

      iex> get_like!(123)
      %Like{}

      iex> get_like!(456)
      ** (Ecto.NoResultsError)

  """
  def get_like!(id), do: Repo.get!(Like, id)

  @doc """
  Creates a like.

  ## Examples

      iex> create_like(%{field: value})
      {:ok, %Like{}}

      iex> create_like(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_like(%Profile{} = profile, %Post{} = post, attrs \\ %{}) do
    {:ok, like} =
      %Like{}
      |> Like.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:profile, profile)
      |> Ecto.Changeset.put_assoc(:post, post)
      |> Repo.insert()

    post = get_post!(like.post_id) |> Repo.preload([:profile, :comments, :likes])
    broadcast({:ok, post}, :post_updated)
  end

  @doc """
  Updates a like.

  ## Examples

      iex> update_like(like, %{field: new_value})
      {:ok, %Like{}}

      iex> update_like(like, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_like(%Like{} = like, attrs) do
    like
    |> Like.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a like.

  ## Examples

      iex> delete_like(like)
      {:ok, %Like{}}

      iex> delete_like(like)
      {:error, %Ecto.Changeset{}}

  """
  def delete_like(%Like{} = like) do
    Repo.delete(like)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking like changes.

  ## Examples

      iex> change_like(like)
      %Ecto.Changeset{data: %Like{}}

  """
  def change_like(%Like{} = like, attrs \\ %{}) do
    Like.changeset(like, attrs)
  end

  alias Shinstagram.Timeline.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments(%Post{id: id}) do
    from(c in Comment, where: c.post_id == ^id) |> Repo.all()
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(%Profile{} = profile, %Post{} = post, attrs \\ %{}) do
    {:ok, comment} =
      %Comment{}
      |> Comment.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:profile, profile)
      |> Ecto.Changeset.put_assoc(:post, post)
      |> Repo.insert()

    post = get_post!(post.id)
    broadcast({:ok, post}, :post_updated)
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
