defmodule Shinstagram.Repo.Migrations.AddSummary do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :summary, :string
    end
  end
end
