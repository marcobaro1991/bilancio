defmodule Bilancio.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, args) do
    Bilancio.Supervisor.start_link(args)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BilancioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
