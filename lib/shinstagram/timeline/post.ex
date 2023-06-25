defmodule Shinstagram.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field(:caption, :string)
    field(:photo, :string)
    belongs_to(:profile, Shinstagram.Profiles.Profile)
    has_many(:likes, Shinstagram.Timeline.Like)
    field(:photo_prompt, :string)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:photo, :caption, :photo_prompt])
    |> validate_required([:photo, :caption, :photo_prompt])
  end
end
