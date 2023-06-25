defmodule Shinstagram.Timeline.Like do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "likes" do
    belongs_to(:profile, Shinstagram.Profiles.Profile)
    belongs_to(:post, Shinstagram.Timeline.Post)
    field(:reasoning)

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:reasoning])
    |> validate_required([])
  end
end
