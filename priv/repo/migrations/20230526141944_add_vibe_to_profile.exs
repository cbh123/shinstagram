defmodule Shinstagram.Repo.Migrations.AddVibeToProfile do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :vibe, :text
    end
  end
end
