defmodule Shinstagram.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "logs" do
    field :text, :string
    field :profile_id, :binary_id
    field :post_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:text, :profile_id, :post_id])
    |> validate_required([:text])
  end
end
