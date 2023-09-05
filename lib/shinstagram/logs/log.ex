defmodule Shinstagram.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "logs" do
    field(:event, :string)
    field(:message, :string)
    field(:emoji, :string)
    belongs_to(:profile, Shinstagram.Profiles.Profile)

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:message, :event, :profile_id, :emoji])
    |> validate_required([:message, :event])
  end
end
