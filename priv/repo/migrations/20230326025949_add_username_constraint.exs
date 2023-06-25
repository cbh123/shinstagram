defmodule Shinstagram.Repo.Migrations.AddUsernameConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:profiles, [:username])
  end
end
