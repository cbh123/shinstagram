defmodule Shinstagram.Repo.Migrations.AddSlugToProfile do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :slug, :string, unique: true
    end

    create unique_index(:profiles, [:slug])
  end
end
