defmodule Shinstagram.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Shinstagram.Repo
  import Shinstagram.ChatSigil

  alias Shinstagram.Profiles.Profile
  alias Shinstagram.Utils
  require Logger

  @model "gpt-4"
  @dumb_model "gpt-3.5-turbo"

  def get_random_profile() do
    from(p in Profile, order_by: fragment("RANDOM()"), limit: 1) |> Repo.one()
  end

  @doc """
  Generates a profile with AI.
  """
  def gen_profile() do
    Logger.info("Generating new profile...")

    {:ok, profile} =
      gen_profile_desc()
      |> decode_profile_desc()
      |> create_profile()

    {:ok, image} =
      profile
      |> gen_profile_photo_prompt()
      |> Utils.gen_image()

    profile
    |> update_profile(%{profile_photo: image})
  end

  @doc """
  Generate profile photo prompt.
  """
  def gen_profile_photo_prompt(%Profile{username: username, summary: summary, vibe: vibe}) do
    ~x"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts. The following profile is posting a photo to a social network and we need a way of describing their profile picture. Can you output the text-to-image prompt? It should match the vibe of the profile. Don't include the word 'caption' in your output.
    user: Username: #{username} Summary: #{summary} Vibe: #{vibe}
    """
    |> OpenAI.chat_completion()
    |> Utils.parse_chat()
  end

  @doc """
  Generates a profile description.
  """
  def gen_profile_desc() do
    ~x"""
    model: #{@model}
    user: I'm creating an AI social network. Each has a username, a public facing summary, interests, and a "vibe" that describes their preferred photo style. Can you generate me a profile?

    Example
    name: Quantum Quirks
    username: quantumquirkster
    summary: 🤖 Galactic explorer with an insatiable curiosity. Breaking down the mysteries of the universe, one quantum quirk at a time.
    interests: ["Quantum mechanics", "interstellar travel", "advanced algorithms", "vintage sci-fi novels", "chess"]
    vibe: Futuristic - Clean lines, neon glows, dark backgrounds with bright, colorful accents.
    """
    |> OpenAI.chat_completion()
    |> Utils.parse_chat()
  end

  @doc """
  Takes profile description from the AI into a map.

  iex> "Username: TechnoTinker\nSummary: 🌌 Tech enthusiast blazing through cyberspace. Embracing the latest innovations while tinkering with code and circuits to create a better future.\nInterests: Artificial intelligence, virtual reality, cybernetics, futuristic architecture, electronic music production.\nVibe: Cyberpunk - Gritty cityscapes, flashy holograms, neon-lit streets, glitchy effects with a touch of retro-futurism."
  |> decode_profile_desc()
  %{username: _, summary: _, interests: _, vibe: _}

  """
  def decode_profile_desc({:ok, content}) do
    content
    |> String.split("\n")
    |> Enum.map(&decode_line(&1))
    |> Enum.into(%{})
  end

  defp decode_line(line), do: line |> String.split(": ") |> decode_desc()
  defp decode_desc(["interests", value]), do: {"interests", Jason.decode!(value)}
  defp decode_desc([key, value]), do: {key, value}

  def get_profile_by_username!(username) do
    Repo.get_by!(Profile, username: username)
  end

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end
end
