defmodule Shinstagram.Repo.Migrations.AddPid do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add(:pid, :string)
    end
  end
end
