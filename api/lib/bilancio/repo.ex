defmodule Bilancio.Repo do
  use Ecto.Repo,
    otp_app: :bilancio,
    adapter: Ecto.Adapters.Postgres
end
