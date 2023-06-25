defmodule Shinstagram.Repo.Migrations.PhotoPrompt do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:photo_prompt, :text)
    end
  end
end
