defmodule Shinstagram.Repo.Migrations.CreateTimeline do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:photo, :string)
      add(:caption, :string)
      add(:profile_id, references(:profiles, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:posts, [:profile_id]))
  end
end
