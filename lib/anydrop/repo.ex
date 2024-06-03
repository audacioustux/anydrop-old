defmodule Anydrop.Repo do
  use Ecto.Repo,
    otp_app: :anydrop,
    adapter: Ecto.Adapters.Postgres
end
