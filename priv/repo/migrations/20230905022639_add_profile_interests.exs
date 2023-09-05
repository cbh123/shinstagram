defmodule Shinstagram.Repo.Migrations.AddProfileInterests do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add(:post_interest, :integer)
      add(:look_interest, :integer)
      add(:sleep_interest, :integer)
    end
  end
end
