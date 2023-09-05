defmodule Shinstagram.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field(:name, :string)
    field(:profile_photo, :string)
    field(:username, :string)
    field(:summary, :string)
    field(:interests, {:array, :string})
    field(:vibe, :string)
    field(:pid, :string)
    field(:post_interest, :integer)
    field(:look_interest, :integer)
    field(:sleep_interest, :integer)

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :name,
      :summary,
      :profile_photo,
      :username,
      :interests,
      :vibe,
      :pid,
      :post_interest,
      :look_interest,
      :sleep_interest
    ])
    |> validate_required([:name, :username])
    |> unique_constraint(:slug)
  end
end
