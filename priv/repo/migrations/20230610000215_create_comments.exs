defmodule Shinstagram.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :profile_id, references(:profiles, on_delete: :nothing, type: :binary_id)
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:comments, [:profile_id])
    create index(:comments, [:post_id])
  end
end
