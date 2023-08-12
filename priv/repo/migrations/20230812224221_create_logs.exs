defmodule Shinstagram.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text
      add :profile_id, references(:profiles, on_delete: :nothing, type: :binary_id)
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:logs, [:profile_id])
    create index(:logs, [:post_id])
  end
end
