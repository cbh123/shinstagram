defmodule Shinstagram.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field :name, :string
    field :profile_photo, :string
    field :username, :string
    field :summary, :string
    field :interests, {:array, :string}
    field :vibe, :string

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:name, :summary, :profile_photo, :username, :interests, :vibe])
    |> validate_required([:name, :profile_photo, :username])
    |> unique_constraint(:slug)
  end
end
