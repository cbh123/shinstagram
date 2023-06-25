defmodule Shinstagram.Repo.Migrations.AddInterestsToProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :interests, {:array, :string}
    end
  end
end
