defmodule Shinstagram.Repo.Migrations.ChangeSlugToUsername do
  use Ecto.Migration

  def change do
    rename table(:profiles), :slug, to: :username
  end
end
