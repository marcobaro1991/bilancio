defmodule Bilancio.Rabbit.Consumer.UserDeactivated do
  @moduledoc false

  alias Amqpx.Basic
  alias Amqpx.Helper
  alias Bilancio.Application.User, as: UserApplication

  require Logger

  @config Application.compile_env!(:bilancio, __MODULE__)
  @queue Application.compile_env!(:bilancio, __MODULE__)[:queue]

  @behaviour Amqpx.Gen.Consumer

  def setup(channel) do
    Helper.declare(channel, @config)
    Basic.consume(channel, @queue, self())
    {:ok, %{}}
  end

  def handle_message(payload, _meta, state) do
    payload
    |> Jason.decode!()
    |> manage_payload()

    {:ok, state}
  end

  def manage_payload(%{"identifier" => user_identifier, "occurred_on" => occurred_on}) do
    case UserApplication.delete(user_identifier) do
      :ok ->
        Logger.info(
          "User #{user_identifier} disattivato il #{occurred_on} e cancellato il: #{DateTime.truncate(DateTime.utc_now(), :second)}"
        )

      _ ->
        Logger.error(
          "User #{user_identifier} disattivato il #{occurred_on} e NON cancellato il: #{DateTime.truncate(DateTime.utc_now(), :second)}"
        )
    end
  end

  def manage_payload(payload) do
    Logger.error("User not deleted, wrong payload #{inspect(payload)}")
    :ok
  end
end
