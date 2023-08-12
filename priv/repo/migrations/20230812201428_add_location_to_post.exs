defmodule Shinstagram.Repo.Migrations.AddLocationToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :location, :string
    end
  end
end
