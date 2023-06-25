defmodule Shinstagram.Repo do
  use Ecto.Repo,
    otp_app: :shinstagram,
    adapter: Ecto.Adapters.Postgres
end
