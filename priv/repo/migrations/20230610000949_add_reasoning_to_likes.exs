defmodule Shinstagram.Repo.Migrations.AddReasoningToLikes do
  use Ecto.Migration

  def change do
    alter table(:likes) do
      add(:reasoning, :text)
    end
  end
end
