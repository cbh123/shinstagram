defmodule Shinstagram.Repo.Migrations.CreateTimeline do
  use Ecto.Migration

  def change do
    create table(:likes, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:profile_id, references(:profiles, on_delete: :nothing, type: :binary_id))
      add(:post_id, references(:posts, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:likes, [:profile_id]))
    create(index(:likes, [:post_id]))
  end
end
