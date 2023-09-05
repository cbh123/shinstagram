defmodule Shinstagram.Repo.Migrations.AddEmojiToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add(:emoji, :string)
    end
  end
end
