defmodule Pain.Repo do
  use Ecto.Repo,
    otp_app: :pain,
    adapter: Ecto.Adapters.Postgres
end
