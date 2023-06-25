defmodule Shinstagram.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field(:body, :string)
    belongs_to(:profile, Shinstagram.Profiles.Profile)
    belongs_to(:post, Shinstagram.Timeline.Post)

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
