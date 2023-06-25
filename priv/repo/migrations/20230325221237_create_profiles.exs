defmodule Shinstagram.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :profile_photo, :string

      timestamps()
    end
  end
end
