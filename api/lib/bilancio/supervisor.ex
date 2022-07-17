defmodule Bilancio.Supervisor do
  @moduledoc false

  use Supervisor

  alias Amqpx.Helper

  @consumers_config Application.compile_env!(:bilancio, :consumers)
  @producer_config Application.compile_env!(:bilancio, :producer)

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children =
      Enum.concat(
        [
          pub_sub(),
          repo(),
          redis(),
          manager(),
          producer(),
          endpoint()
        ],
        consumers()
      )

    opts = [strategy: :one_for_one, max_restarts: 6]
    Supervisor.init(children, opts)
  end

  defp repo do
    Bilancio.Repo
  end

  defp pub_sub do
    {Phoenix.PubSub, name: Bilancio.PubSub}
  end

  defp redis do
    Bilancio.Redis.Conn
  end

  defp manager do
    amqp_config = Application.get_env(:bilancio, :amqp_connection)
    Helper.manager_supervisor_configuration(amqp_config)
  end

  defp producer do
    Helper.producer_supervisor_configuration(@producer_config)
  end

  defp consumers do
    Helper.consumers_supervisor_configuration(@consumers_config)
  end

  def endpoint do
    Supervisor.child_spec({BilancioWeb.Endpoint, []}, shutdown: 60_000)
  end
end
