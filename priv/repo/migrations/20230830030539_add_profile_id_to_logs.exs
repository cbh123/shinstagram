defmodule Shinstagram.Repo.Migrations.AddProfileIdToLogs do
  use Ecto.Migration

  def change do
    rename(table(:logs), :status, to: :message)

    alter table(:logs) do
      add(:profile_id, references(:profiles, on_delete: :nothing, type: :binary_id))
    end

    create(index(:logs, [:profile_id]))
  end
end
